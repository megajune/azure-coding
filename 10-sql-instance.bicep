@description('The name of the tier you want this resource to be a member of.')
param tier string

@description('Virtual network name')
param virtualNetworkName string

@description('The name of the SQL logical server.')
param SQLserverName string

@description('The name of the SQL Database.')
param sqlDBName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL logical server.')
param administratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param SQLadministratorLoginPassword string

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: SQLserverName
  location: location
  properties: {
    publicNetworkAccess: 'Disabled'
    administratorLogin: administratorLogin
    administratorLoginPassword: SQLadministratorLoginPassword
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDBName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}



var WorkLoadSubnetName = 'WorkLoadSubnet'
var privateEndpointName = '${tier}vnet-sqldb-privateendpoint'

//var privateDnsZoneName = '${tier}vnet-privatelink${environment().suffixes.sqlServerHostname}'
//var pvtEndpointDnsGroupName = '${privateEndpointName}/${tier}dnsgroupname'
//var subnet = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, azureFirewallSubnetName)
//var vnetid = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName)


//This may need to be broken out into it's own script if it throws an error?
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
          privateLinkServiceId: resourceId('Microsoft.Sql/servers', SQLserverName)
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

//Depending on the version of the database, this may not be supported.
resource sqlDBEncryptionState 'Microsoft.Sql/servers/databases/transparentDataEncryption@2022-05-01-preview' = {
  name: 'cryptsqlDB'
  parent: sqlDB
  properties: {
    state: 'Enabled'
  }
}
