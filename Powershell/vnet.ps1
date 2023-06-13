$rg = Get-AzureRMResourceGroup

$vnet = @{
    Name = 'vnet-1'
    ResourceGroupName = $rg.name
    Location = $rg.location
    AddressPrefix = '10.0.0.0/16'
}
$virtualNetwork = New-AzVirtualNetwork @vnet