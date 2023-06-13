$rg = Get-AzureRMResourceGroup

<#param (
    [string]$vnetName = "vnet-1",
    [Parameter(Mandatory=$true)][string]$vnetName
    #[string]$password = $( Read-Host "Input password, please" )
)
param (
    [string]$addressPrefix = "10.212.0.0/24",
    [Parameter(Mandatory=$true)][string]$addressPrefix
    #[string]$password = $( Read-Host "Input password, please" )
)#>

$vnet = @{
    Name = $vnetName
    ResourceGroupName = $rg.ResourceGroupName
    Location = $rg.Location
    AddressPrefix = $addressPrefix
}
$virtualNetwork = New-AzVirtualNetwork @vnet