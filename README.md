//

$rg = Get-AzureRMResourceGroup

#Deploy the Vnet

New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 05-network.bicep -TemplateParameterFile 05-network-parameters.json



$JSON = Get-Content -Path ./05-network-parameters.json | ConvertFrom-Json