#This script is used to generate Bicep configuration files. The purpose is to genearete infrastructure in an Azure dev envinronment. 
#Author: Jonathan Martin

$rg = Get-AzureRMResourceGroup

#Begin gathering parameters

$envname = Read-Host "Enter a environment abbreviation" -MaskInput

Write-Host "$envname"

#Deploy the Vnet

New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 05-network.bicep -TemplateParameterFile 05-network-parameters.json