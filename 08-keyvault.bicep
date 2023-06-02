//This will still need permissions granted. By default, access from public IPs is not allowed.

param tier string //= 'webapp-'
//param virtualNetworkName string = '${tier}vnet'

@description('The name of the key vault to be created.')
param vaultName string = '${tier}kv-${uniqueString(resourceGroup().id)}'

@description('The name of the key to be created.')
param keyName string = '${tier}key-test'

@description('The location of the resources')
param location string = resourceGroup().location

@description('The SKU of the vault to be created.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('The JsonWebKeyType of the key to be created.')
@allowed([
  'EC'
  'EC-HSM'
  'RSA'
  'RSA-HSM'
])
param keyType string = 'RSA'

@description('The permitted JSON web key operations of the key to be created.')
param keyOps array = []

@description('The size in bits of the key to be created.')
param keySize int = 2048

@description('The JsonWebKeyCurveName of the key to be created.')
@allowed([
  ''
  'P-256'
  'P-256K'
  'P-384'
  'P-521'
])
param curveName string = ''

//var WorkLoadSubnetName = 'WorkLoadSubnet'
//var privateEndpointName = '${tier}vnet-kv-privateendpoint'

//resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: vaultName
  location: location
  properties: {
    accessPolicies:[]
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'deny'
      //bypass: 'None'  //This should be enabled, but ACloudGuru doesn't allow for this.
      bypass: 'AzureServices'
    }
  }
}

//resource key 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
resource key 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  parent: vault
  name: keyName
  properties: {
    kty: keyType
    keyOps: keyOps
    keySize: keySize
    curveName: curveName
  }
}

//var privateDnsZoneName = '${tier}vnet-privatelink${environment().suffixes.sqlServerHostname}'
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

//resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//  name: privateDnsZoneName
//  location: location
//  properties: {}
//}

//resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//  parent: privateDnsZone
//  name: '${privateDnsZoneName}-link'
//  location: location
//  properties: {
//    registrationEnabled: false
//    virtualNetwork: {
//      id: resourceId('Microsoft.Network/virtualNetworks', virtualNetworkName)
//    }
//  }
//}

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
//  dependsOn: [
//    privateEndpoint
//  ]
//}

output proxyKey object = key.properties
