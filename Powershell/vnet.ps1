#./vnet.ps1 -vnetName "test1212" -AddressPrefix "10.212.0.0/24"
param(
[Parameter(Mandatory, HelpMessage = 'Please enter a subnet in the form a.b.c.d/#', ValueFromPipeline, Position = 0)]
[string]$vnetName,
[string]$AddressPrefix
)
$rg = Get-AzureRMResourceGroup

if ($AddressPrefix -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}$') {
    #Split IP and subnet
    $IP = ($AddressPrefix -split '\/')[0]
    [int] $SubnetBits = ($AddressPrefix -split '\/')[1]
    if ($SubnetBits -lt 7 -or $SubnetBits -gt 30) {
        Write-Error -Message 'The network mask (in CIDR notation) following the / must be between 7 and 30'
        break
    }
    $Octets = $IP -split '\.'
    $networkAddressNumber = $Octets[0]+'.'+$Octets[1]+'.'+$Octets[2]
} else {
    Write-Error -Message "Subnet [$AddressPrefix] is not in a valid format"
    break
}

<#param (
    [string]$vnetName = "vnet-1",
    [Parameter(Mandatory=$true)][string]$vnetName
    #[string]$password = $( Read-Host "Input password, please" )
)#>

$vnet = @{
    Name = $vnetName
    ResourceGroupName = $rg.ResourceGroupName
    Location = $rg.Location
    AddressPrefix = $addressPrefix
}
$virtualNetwork = New-AzVirtualNetwork @vnet

$subnetnames = 'AzureFirewallSubnet','AzureBastionSubnet','WorkloadSubnet'


foreach ($name in $subnetnames){
$subnet = @{
    Name = $name
    VirtualNetwork = $virtualNetwork
    AddressPrefix = $networkAddressNumber+'.0/28'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet
}