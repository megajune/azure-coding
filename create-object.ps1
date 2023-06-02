#This script is used to generate Bicep configuration files. The purpose is to genearete infrastructure in an Azure dev envinronment. 
#Author: Jonathan Martin

$rg = Get-AzureRMResourceGroup

#Begin gathering parameters
if (! $args[0] ){
    Write-Output "This empty"
    $envname = Read-Host "Enter an environment abbreviation"
    }
else {
    $envname = $arg1
}

#$envname = Read-Host "Enter a environment abbreviation"

Write-Host "$envname"

#Deploy the Vnet

New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 05-network.bicep -TemplateParameterFile 05-network-parameters.json