#This script is used to generate Bicep configuration files. The purpose is to genearete infrastructure in an Azure dev envinronment. 
#Author: Jonathan Martin

$rg = Get-AzureRMResourceGroup

$JSON = Get-Content -Path 05-network-parameters.json | ConvertFrom-Json

#Begin gathering parameters

$tier=$JSON.parameters.tier
$virtualNetworkName=$JSON.parameters.virtualNetworkName
$vnetAddressPrefix=$JSON.parameters.vnetAddressPrefix
$bastionAddressPrefix=$JSON.parameters.bastionAddressPrefix
$azureFirewallSubnetPrefix=$JSON.parameters.azureFirewallSubnetPrefix
$WorkLoadSubnetPrefix=$JSON.parameters.WorkLoadSubnetPrefix
$PrivateFirewallIP=$JSON.parameters.PrivateFirewallIP

Write-Host "The following network is about to be generated:"
Write-Host "Tier level " $tier


#Deploy the Vnet

New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 05-network.bicep -TemplateParameterFile 05-network-parameters.json