//

$rg = Get-AzureRMResourceGroup

#Deploy the Vnet

New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 05-webapp-network.bicep -TemplateParameterFile ./05-webapp-network-parameters.json
New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 07-bastion.bicep -TemplateParameterFile 07-bastion-parameters.json
New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 11-linux-vm.bicep -TemplateParameterFile 11-linux-vm-parameters.json

New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile 05-network.bicep -TemplateParameterFile 05-network-parameters.json

$JSON = Get-Content -Path ./05-network-parameters.json | ConvertFrom-Json

git clone https://github.com/megajune/azure-coding/



#location of Nessus in Docker = docker.io/tenable/nessus:latest-ubuntu