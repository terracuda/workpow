#Author:  https://github.com/terracuda/workpow
               
				#Welcome message
				
clear-host
echo ""
echo " ___________________________ "
echo "|                           |"
echo "|      CodeSigner v1.1      |" 
echo "|     Author: TerraCuda     |"
echo "|___________________________|"
echo ""

                   #Variables
$path = (Get-Item -Path ".\").FullName
$unfiles = Get-ChildItem $path -Exclude '*.ps1'
$FLTotcount = ($unfiles).count
$DateStamp = get-date


 if ($FLTotcount -gt 0)
{

echo "$FLTotcount files were assigned:"
  
  foreach($unfile in $unfiles)

{

$prefix = Get-Random -InputObject "test_cert", "tempo", "code_sign"
$num = Get-Random -Maximum 50000000 -Minimum 10000000

New-SelfSignedCertificate -Type CodeSigningCert -DnsName "$num.$prefix.com" -Subject "CN=RRR $prefix $num" -CertStoreLocation cert:\CurrentUser\My | Out-Null

$cert = (Get-ChildItem cert:\CurrentUser\my –CodeSigningCert)[-1]

$filename = ($unfile).name

Set-AuthenticodeSignature -FilePath "$filename" -Certificate $cert -IncludeChain "All" -TimeStampServer "http://timestamp.comodoca.com/authenticode"

$tprint = ($cert).thumbprint

Remove-item -Path cert:\CurrentUser\my\$tprint -Deletekey

# echo $filename

echo "--------------------------------"



}


exit
}

echo "Please prapare the unsigned executable files and put them into this folder."
exit