#This script is used to generate Bicep configuration files. The purpose is to genearete infrastructure in an Azure dev envinronment. 
#Author: Jonathan Martin

$rg = Get-AzureRMResourceGroup

$JSON = Get-Content -Path 05-network-parameters.json | ConvertFrom-Json

#Begin gathering parameters

$tier=($JSON.parameters.tier).value
$virtualNetworkName=($JSON.parameters.virtualNetworkName).value
$vnetAddressPrefix=($JSON.parameters.vnetAddressPrefix).value
$bastionAddressPrefix=($JSON.parameters.bastionAddressPrefix).value
$azureFirewallSubnetPrefix=($JSON.parameters.azureFirewallSubnetPrefix).value
$WorkLoadSubnetPrefix=($JSON.parameters.WorkLoadSubnetPrefix).value
$PrivateFirewallIP=($JSON.parameters.PrivateFirewallIP).value

Write-Host "The following environment is about to be generated:"
Write-Host "VNET/Tier prefix " $tier " "
Write-Host "VNET Name " $virtualNetworkName " "
Write-Host "Subnet prefix " $vnetAddressPrefix
Write-Host "Bastion subnet address space " $bastionAddressPrefix
Write-Host "Azure firewall subnet address space " $azureFirewallSubnetPrefix
Write-Host "Workload subnet address space " $WorkLoadSubnetPrefix
Write-Host "(Informational) Workload subnet address space " $PrivateFirewallIP

#Deploy the Vnet

New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 05-network.bicep -TemplateParameterFile 05-network-parameters.json