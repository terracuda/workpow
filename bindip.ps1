               # Set some variables
$GUsername = 'Tester'                                                     # guest machine username
$GPass = 'test'                                                           # guest machine user password
$Desktop = "C:\Users\Administrator\Desktop\"                              # path to save the RDP profiles (Desktop by default)
$SRCpath = "D:\workspace\script\source.rdp"                               # path to RDP source profile
$Octet = '(?:0?0?[0-9]|0?[1-9][0-9]|1[0-9]{2}|2[0-5][0-5]|2[0-4][0-9])'   # regex for IP V4 filter
$IPv4Regex = "^(?:$Octet\.){3}$Octet$"                                    # regex for IP V4 filter

               # Clean the old array values
$VMIPs = @()
$VMNames = @()
$VMLMacs = @()
               
               # Detect how many VMs are running with Network Adapters and Legacy Network Adapters.
$LNAVMS = (get-vmnetworkadapter * | Where-Object { $_.name -eq 'Legacy Network Adapter' -and $_.Status -eq 'Ok' })
$NAVMS = (get-vmnetworkadapter * | Where-Object { $_.name -eq 'Network Adapter' -and $_.Status -eq 'Ok' })                           
$LNAVMScount = ($LNAVMS).count
$NAVMScount = ($NAVMS).count
$VMTotcount = $LNAVMScount + $NAVMScount

               # In case when VMs with LNA are running - collect the IP-addresses using the ARP table and names.
  if ($LNAVMScount -gt 0) 
{
               # Collect the MAC addresses for VMs with Legacy Network Adapters.
$VMLMacs += ($LNAVMS).MacAddress

               #Changing the MACs formats.
$VMLMacs = $VMLMacs -replace '..(?!$)', '$&-'

$VMIPs += (Get-NetNeighbor | Where-Object { $_.LinkLayerAddress -eq $VMLMacs -and $_.State -ne 'Stale' }).IPAddress
$VMNames += ($LNAVMS).VMName
}

               # In case when VMs with Network Adapters are running - collect the IP-addresses and names.
  if ($NAVMScount -gt 0)              
{
$VMIPs += ($NAVMS).ipaddresses -match $IPv4Regex

$VMNames += ($NAVMS).VMName
}

 if ($VMTotcount -gt 0)
{

echo "Connection links and rules were created for the following VMs:"
  for ($i=0; $i -lt $VMTotcount; $i++)
{

$VMIP = $VMIPs[$i]
$VMName = $VMNames[$i]

               # Create the appropriate records in Windows Credential Manager. This should help to enter the VM's user credentials automatically.
cmdkey /generic:TERMSRV/$VMIP /user:$GUsername /pass:$GPass | Out-Null

               # Create the RDP profiles for each VM on Desktop, based on the pattern RDP file.
Get-Content $SRCpath | out-file $Desktop\$VMName.rdp

               # Add the assigned IPV4 address to each created profile.
Write-Output "full address:s:$VMIP" | out-file $Desktop\$VMName.rdp -append

               # Add the Guest Machine's username to each created profile.
Write-Output "username:s:$GUsername" | out-file $Desktop\$VMName.rdp -append

echo "--------------------------------"
echo $VMIP $VMName

}
exit
}

echo "Sorry, no running VMs were detected"

exit
