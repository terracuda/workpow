# Variables

$GUsername = Tester                                                       # guest machine username
$GPass = test                                                             # guest machine user password
$Desktop = "C:\Users\Administrator\Desktop\"                              # path to save the RDP profiles (Desktop by default)
$SRCpath = "D:\workspace\script\source.rdp"                               # path to RDP source profile
$Octet = '(?:0?0?[0-9]|0?[1-9][0-9]|1[0-9]{2}|2[0-5][0-5]|2[0-4][0-9])'   # regex for IP V4 filter
$IPv4Regex = "^(?:$Octet\.){3}$Octet$"                                    # regex for IP V4 filter


# Set the VM's names and IPV4 addresses as array (Network Adapters Only).
$VMIPs = @()
$VMIPs += (get-vmnetworkadapter * | Where-Object { $_.ipaddresses -gt '0' }).ipaddresses -match $IPv4Regex
$VMNames = @()
$VMNames += (get-vmnetworkadapter * | Where-Object { $_.ipaddresses -gt '0' }).VMName

# Set the VM's names and IPV4 addresses as array (Workaround for legacy Network Adapters).
$VMLMacs = @()
$VMLMacs += (get-vmnetworkadapter * | Where-Object { $_.name -eq 'Legacy Network Adapter' -and $_.Status -eq 'Ok' }).MacAddress

if ($VMLMacs -gt "1") 
{
#Changing the MACs fomrats.
$VMLMacs = $VMLMacs -replace '..(?!$)', '$&-'

$VMIPs += (Get-NetNeighbor | Where-Object { $_.LinkLayerAddress -eq $VMLMacs -and $_.State -ne 'Stale' }).IPAddress
$VMNames += (get-vmnetworkadapter * | Where-Object { $_.name -eq 'Legacy Network Adapter' -and $_.Status -eq 'Ok' }).VMName
}

echo "Connection links and rules were created for the following VMs:"

for ($i=0; $i -lt $VMIPs.Count; $i++)
{

$VMIP = $VMIPs[$i]
$VMName = $VMNames[$i]

# Create the appropriate records in Windows Credential Manager. This should help to enter the VM's user credentials automatically.
cmdkey /generic:TERMSRV/$VMIP /user:$GUsername /pass:$GPass | Out-Null

# Create the RDP profiles for each VM on Desktop, based on the pattern RDP file.
Get-Content $SRCpath | out-file $Desktop\$VMName.rdp

# Add the current IPV4 address to each created profile.
Write-Output "full address:s:$VMIP" | out-file $Desktop\$VMName.rdp -append

echo "--------------------------------"
echo $VMIP $VMName


}
