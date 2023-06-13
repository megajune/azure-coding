$rg = Get-AzureRMResourceGroup
$rg.name

$vnet = @{
    Name = 'vnet-1'
    ResourceGroupName = $rg.ResourceGroupName
    Location = $rg.Location
    AddressPrefix = '10.0.0.0/16'
}
$virtualNetwork = New-AzVirtualNetwork @vnet