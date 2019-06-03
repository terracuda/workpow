#Author:  https://github.com/terracuda/workpow
  
                               #Welcome message
clear-host
echo ""
echo " ___________________________ "
echo "|                           |"
echo "|      SignTruster v1.1     |" 
echo "|     Author: TerraCuda     |"
echo "|___________________________|"
echo ""

                   #Variables
$path = (Get-Item -Path ".\").FullName
$trusted_path = "cert:\localmachine\authroot"
$signfiles = Get-ChildItem $path -Exclude '*.ps1' | ForEach-object {Get-AuthenticodeSignature $_} | Where-Object {$_.Status -ne "NotSigned"}
$signTotcount = ($signfiles).count
# $DateStamp = get-date


 if ($signTotcount -gt 0)
 {

echo "$signTotcount signed executable files were found:"
 
   
          foreach($signfile in $signfiles)
          {

$cert = ($signfile).SignerCertificate

Export-Certificate -Cert $cert -FilePath $path\temp.p7b -Type p7b | Out-Null

Start-Sleep -m 200

Import-Certificate -filepath $path\temp.p7b -CertStoreLocation $trusted_path | Out-Null
Start-Sleep -m 200

Remove-item $path\temp.p7b  -Confirm:$false -Force

Start-Sleep -m 200

echo $cert
echo "----------------------------------------"

          }


exit
 }

echo "Please put the signed executable files into this folder."
exit