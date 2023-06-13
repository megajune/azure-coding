@description('The tier of this script. Change this for each environment')
param tier string
param virtualNetworkName string = '${tier}vnet'
var WorkLoadSubnetName = 'WorkLoadSubnet'

@description('The name of the key vault to be created.')
param vaultName string = '${tier}kv-${uniqueString(resourceGroup().id)}'

@description('The location of the resources')
param location string = resourceGroup().location

var privateEndpointName = '${tier}vnet-kv-privateendpoint'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, WorkLoadSubnetName)
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.KeyVault/vaults', vaultName)
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}
