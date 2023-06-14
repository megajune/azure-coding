param location string = 'eastus'
param virtualWanName string = 'MyVirtualWAN'
param virtualHubName string = 'MyVirtualHub'
param hubVnetName string = 'HubVNet'
param hubVnetAddressPrefix string = '10.0.0.0/16'
param hubVnetSubnetName string = 'HubSubnet'
param hubVnetSubnetPrefix string = '10.0.0.0/24'
param spoke1VnetName string = 'Spoke1VNet'
param spoke1VnetAddressPrefix string = '10.1.0.0/16'
param spoke1VnetSubnetName string = 'Spoke1Subnet'
param spoke1VnetSubnetPrefix string = '10.1.0.0/24'
param spoke2VnetName string = 'Spoke2VNet'
param spoke2VnetAddressPrefix string = '10.2.0.0/16'
param spoke2VnetSubnetName string = 'Spoke2Subnet'
param spoke2VnetSubnetPrefix string = '10.2.0.0/24'
param azureFirewallName string = 'MyAzureFirewall'
param azureFirewallSubnetPrefix string = '10.0.1.0/24'

resource virtualWan 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: virtualWanName
  location: location
  sku: {
    family: 'WanSku'
    name: 'WAN_Premium'
  }
}

resource virtualHub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: virtualHubName
  location: location
  sku: {
    family: 'Standard'
    name: 'Standard'
  }
  properties: {
    virtualWan: {
      id: virtualWan.id
    }
  }
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: hubVnetSubnetName
        properties: {
          addressPrefix: hubVnetSubnetPrefix
        }
      }
    ]
  }
}

resource spoke1Vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: spoke1VnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        spoke1VnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: spoke1VnetSubnetName
        properties: {
          addressPrefix: spoke1VnetSubnetPrefix
        }
      }
    ]
  }
}

resource spoke2Vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: spoke2VnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        spoke2VnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: spoke2VnetSubnetName
        properties: {
          addressPrefix: spoke2VnetSubnetPrefix
        }
      }
    ]
  }
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: azureFirewallName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          subnet: {
            id: '${hubVnet.id}/subnets/AzureFirewallSubnet'
          }
          publicIpAddress: {
            id: 'PublicIpAddressResourceId'
          }
        }
      }
    ]
  }
  dependsOn: [
    hubVnet
  ]
}

resource hubVirtualNetworkConnection 'Microsoft.Network/hubVirtualNetworkConnections@2021-02-01' = {
  name: '${virtualHubName}-${hubVnetName}'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
  dependsOn: [
    virtualHub
    hubVnet
  ]
}

resource spoke1VirtualNetworkConnection 'Microsoft.Network/hubVirtualNetworkConnections@2021-02-01' = {
  name: '${virtualHubName}-${spoke1VnetName}'
  properties: {
    remoteVirtualNetwork: {
      id: spoke1Vnet.id
    }
  }
  dependsOn: [
    virtualHub
    spoke1Vnet
  ]
}

resource spoke2VirtualNetworkConnection 'Microsoft.Network/hubVirtualNetworkConnections@2021-02-01' = {
  name: '${virtualHubName}-${spoke2VnetName}'
  properties: {
    remoteVirtualNetwork: {
      id: spoke2Vnet.id
    }
  }
  dependsOn: [
    virtualHub
    spoke2Vnet
  ]
}

output virtualWanId string = virtualWan.id
output virtualHubId string = virtualHub.id
output hubVnetId string = hubVnet.id
output spoke1VnetId string = spoke1Vnet.id
output spoke2VnetId string = spoke2Vnet.id
output azureFirewallId string = azureFirewall.id
