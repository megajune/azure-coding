@description('The tier of this script. Change this for each environment')
param tier string

@description('Virtual network name')
param virtualNetworkName string = '${tier}vnet'

@description('Azure Firewall name')
param firewallName string = '${tier}fw'

@description('The address prefix to use for the Bastion subnet. Change this for each environment')
param bastionAddressPrefix string// = '10.10.0.64/26'
param BastionSubnet string = 'AzureBastionSubnet'

@description('Number of public IP addresses for the Azure Firewall')
@minValue(1)
@maxValue(100)
param numberOfPublicIPAddresses int = 1

@description('Zone numbers e.g. 1,2,3.')
param availabilityZones array = []

@description('Location for all resources.')
param location string = resourceGroup().location
param infraIpGroupName string = '${tier}infra-ipgroup-${uniqueString(resourceGroup().id)}'
param workloadIpGroupName string = '${tier}workload-ipgroup-${uniqueString(resourceGroup().id)}'
param firewallPolicyName string = '${tier}${firewallName}-firewallPolicy'

param vnetAddressPrefix string
param azureFirewallSubnetPrefix string
param PrivateFirewallIP string
param WorkLoadSubnetPrefix string
var WorkLoadSubnetName = 'WorkLoadSubnet'
var routeTableName = '${tier}routes'
var routeTableId = resourceId('Microsoft.Network/routeTables', routeTableName)
var publicIPNamePrefix = '${tier}pip-fw'
var azurepublicIpname = publicIPNamePrefix
var azureFirewallSubnetName = 'AzureFirewallSubnet'
var azureFirewallSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, azureFirewallSubnetName)
var azureFirewallPublicIpId = resourceId('Microsoft.Network/publicIPAddresses', publicIPNamePrefix)
var azureFirewallIpConfigurations = [for i in range(0, numberOfPublicIPAddresses): {
  name: 'IpConf${i}'
  properties: {
    subnet: ((i == 0) ? json('{"id": "${azureFirewallSubnetId}"}') : null)
    publicIPAddress: {
      id: '${azureFirewallPublicIpId}${i + 1}'
    }
  }
}]

resource workloadIpGroup 'Microsoft.Network/ipGroups@2022-01-01' = {
  name: workloadIpGroupName
  location: location
  properties: {
    ipAddresses: [
      '10.10.0.128/26'
    ]
  }
}

resource infraIpGroup 'Microsoft.Network/ipGroups@2022-01-01' = {
  name: infraIpGroupName
  location: location
  properties: {
    ipAddresses: [
      '10.10.0.64/26'
      '10.10.0.0/26'
    ]
  }
}
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = [for i in range(0, numberOfPublicIPAddresses): {
  name: '${azurepublicIpname}${i + 1}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}]

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01'= {
  name: firewallPolicyName
  location: location
  properties: {
    threatIntelMode: 'Alert'
  }
}

resource networkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  parent: firewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'azure-global-services-nrc'
        priority: 1250
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'time-windows'
            ipProtocols: [
              'UDP'
            ]
            destinationAddresses: [
              '13.86.101.172'
            ]
            sourceIpGroups: [
              workloadIpGroup.id
              infraIpGroup.id
            ]
            destinationPorts: [
              '123'
            ]
          }
        ]
      }
    ]
  }
}

resource applicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  parent: firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  dependsOn: [
    networkRuleCollectionGroup
  ]
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'global-rule-url-arc'
        priority: 1000
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'winupdate-rule-01'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            fqdnTags: [
              'WindowsUpdate'
            ]
            terminateTLS: false
            sourceIpGroups: [
              workloadIpGroup.id
              infraIpGroup.id
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Update-Ubuntu'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            targetFqdns: [
              '*.ubuntu.com'
            ]
            terminateTLS: false
            sourceIpGroups: [
              workloadIpGroup.id
              infraIpGroup.id
            ]
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'Global-rules-arc'
        priority: 1202
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'global-rule-01'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              'www.microsoft.com'
            ]
            terminateTLS: false
            sourceIpGroups: [
              workloadIpGroup.id
              infraIpGroup.id
            ]
          }
        ]
      }
    ]
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-03-01' = {
  name: firewallName
  location: location
  zones: ((length(availabilityZones) == 0) ? null : availabilityZones)
  dependsOn: [
    vnet
    publicIpAddress
    workloadIpGroup
    infraIpGroup
    networkRuleCollectionGroup
    applicationRuleCollectionGroup
  ]
  properties: {
    ipConfigurations: azureFirewallIpConfigurations
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetworkName
  location: location
  tags: {
    displayName: virtualNetworkName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: azureFirewallSubnetName
        properties: {
          addressPrefix: azureFirewallSubnetPrefix
        }
      }
      {
        name: WorkLoadSubnetName
        properties: {
          addressPrefix: WorkLoadSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: BastionSubnet
        properties: {
          addressPrefix: bastionAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
    enableDdosProtection: false
  }
}


var routeTables = [
  {
    name: '${tier}routes'
    routes: [
      {
        name: 'routetoInternet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance' //If firewall
          nextHopIpAddress: PrivateFirewallIP 
        }
      }
      {
        name: 'internalRouteToVwan'
        properties: {
          addressPrefix: '10.10.0.0/16'
          nextHopType: 'VirtualAppliance' //If firewall
          nextHopIpAddress: PrivateFirewallIP 
        }
      }
//      {
//        name: 'routetoDBTier'
//        properties: {
//          addressPrefix: '10.0.5.0/24'
//          nextHopType: 'VirtualAppliance' //If firewall
//          nextHopIpAddress: '10.0.2.4' 
//        }
//      }      
//      {
//        name: 'udr-cloudninjawebiste-001'
//        properties: {
//          addressPrefix: '185.20.205.57/32'
//          nextHopType: 'Internet'
//        }
//      }
//    ]
//  }
//  {
//    name: 'rt-domainservices-routes'
//    routes: [
//      {
//        name: 'udr-forcedtunneling-001'
//        properties: {
//          addressPrefix: '0.0.0.0/0'
//          nextHopType: 'VirtualNetworkGateway' //If VPN
//          nextHopIpAddress: '10.0.2.4'
//        }
//      }      
    ]
  }    
]

//param routeTables array
resource routeTablename_resource 'Microsoft.Network/routeTables@2020-03-01' = [for routeTable in routeTables: {
  name: routeTable.name
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: routeTable.routes
  }
}]

resource Subnets 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: WorkLoadSubnetName
  parent: vnet
  properties: {
    addressPrefix: WorkLoadSubnetPrefix
    routeTable:{
      id: routeTableId // assign the route table
    }
  }
}
