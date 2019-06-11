#Author:  https://github.com/terracuda/workpow

#It uses the ResorceHacker util to unpack/pack the composed executable files.
#Download the latest version of ResourceHacker and place the ResourceHacker.exe in the folder with this script or correct the path to this executable file.

                #Welcome message
clear-host
echo ""
echo " ___________________________ "
echo "|                           |"
echo "|   PE_cloner_signer v1.3   |" 
echo "|     Author: TerraCuda     |"
echo "|___________________________|"
echo ""

                   #Variables
$count = 10        #how many files will be created
$path = (Get-Item -Path ".\").FullName
$target = Get-ChildItem $path\*.exe -Exclude "*_n.exe", "ResourceHacker.exe"           "ResourceHacker.exe and recently created PE will be skipped"
$targets = $target -replace '.exe',''
$FLTotcount = ($unfiles).count
$DateStamp = get-date

.\ResourceHacker.exe -open $target -save source.rc -action extract -mask "VERSIONINFO,,"
Start-Sleep -m 250

for ($i=0; $i -lt $count; $i++)
{

                 # Generate new file version
$num1 = Get-Random -Maximum 9 -Minimum 0
$num2 = Get-Random -Maximum 9 -Minimum 0
$num3 = Get-Random -Maximum 9 -Minimum 0
$num4 = Get-Random -Maximum 9 -Minimum 0
$newver = "$num1,$num2,$num3,$num4"
$prefix = Get-Random -InputObject "test", "QA", "CCS"

                 # replace the old file version with the new one
((Get-Content -path $path\source.rc -Raw) -replace '[0-9][,.][0-9][,.][0-9][,.][0-9]',$newver) | Set-Content -Path $path\source.rc


                 # compiling the RC source
.\ResourceHacker.exe -open source.rc -save source.res -action compile -log NUL

Start-Sleep -m 120

                 # replace the version resource in the target file and compose the new one.
$newtarget = "$($targets)_$($i)_n.exe"
.\ResourceHacker.exe -open $target -save $newtarget -action addoverwrite -res source.res -mask VERSION INFO
echo "File $newtarget has been created"

New-SelfSignedCertificate -Type CodeSigningCert -DnsName "$newver.$prefix.com" -Subject "CN=RRR $prefix $newver" -CertStoreLocation cert:\CurrentUser\My | Out-Null
$cert = (Get-ChildItem cert:\CurrentUser\my –CodeSigningCert)[-1]
Set-AuthenticodeSignature -FilePath "$newtarget" -Certificate $cert -IncludeChain "All" -TimeStampServer "http://timestamp.comodoca.com/authenticode"
$tprint = ($cert).thumbprint

Remove-item -Path cert:\CurrentUser\my\$tprint -Deletekey
Remove-item -Path $path\source.res

echo "--------------------------------"

}


Remove-item -Path $path\source.rc
exit
