//This will need to be customized
param location string = resourceGroup().location
param vnetName string
param subnetName string
param publicIPName string
param publicIPType string = 'Static'
param nicName string
param vmName string
param vmSize string = 'Standard_DS2_v2'
param adminUsername string
@secure()
param adminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPType
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.id //this need to be a subnet!!
          }
          publicIPAddress: {
            id: publicIP.id //This is likely to be removed!!
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
      }
      imageReference: {
        publisher: 'Tenable'
        offer: 'Tenable-Nessus'
        sku: 'Nessus-8-17'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output publicIPName string = publicIP.name
output publicIPFQDN string = publicIP.properties.dnsSettings.fqdn
