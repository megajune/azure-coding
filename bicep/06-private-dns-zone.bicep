//This deployment template is disallowed by policy in my dev environment. However, it should work with a little tuning.

param tier string

param virtualNetworkName string

param location string = resourceGroup().location

//param pvtEndpointDnsGroupName string


var privateDnsZoneName = '${tier}vnet.com}'

//var pvtEndpointDnsGroupName = '${privateEndpointName}/${tier}dnsgroupname'
//var subnet = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, azureFirewallSubnetName)
//var vnetid = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName)

//This may need to be broken out into it's own script if it throws an error like "The specified vault <some vault name> could not be found."
//This is because the above keyvault being referenced in the following 'private endpoint' wasn't created fast enough.


//resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
//  name: privateEndpointName
//  location: location
//  properties: {
//    subnet: {
//      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, WorkLoadSubnetName)
//    }
//    privateLinkServiceConnections: [
//      {
//        name: privateEndpointName
//        properties: {
//          privateLinkServiceId: resourceId('Microsoft.KeyVault/vaults', vaultName)
//          groupIds: [
//            'vault'
//          ]
//        }
//      }
//    ]
//  }
//}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  //location: location
  properties: {}
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: location
  properties: {
    registrationEnabled: true
    virtualNetwork: {
     id: resourceId('Microsoft.Network/virtualNetworks', virtualNetworkName)
    }
  }
}

//resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
//  name: pvtEndpointDnsGroupName
//  properties: {
//    privateDnsZoneConfigs: [
//      {
//        name: 'config1'
//        properties: {
//          privateDnsZoneId: privateDnsZone.id
//        }
//      }
//    ]
//  }
//}
