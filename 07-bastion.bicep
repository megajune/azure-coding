param location string = resourceGroup().location

@description('The tier of this script. Change this for each environment')
param tier string //= 'webapp-'

@description('Virtual network name')
param virtualNetworkName string = '${tier}vnet'

param BastionResourceID string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, BastionSubnet)

param BastionpublicIpName string = '${tier}pip-bastion'

@description('The name of the Bastion host')
param bastionHostName string = '${tier}bastion-jumpbox'

param BastionSubnet string = 'AzureBastionSubnet'

resource publicIpAddressForBastion 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: BastionpublicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: BastionResourceID
          }
          publicIPAddress: {
            id: publicIpAddressForBastion.id
          }
        }
      }
    ]
  }
}
