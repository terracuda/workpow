#NOT READY!
#Author:  https://github.com/terracuda/workpow
               
                #Welcome message
clear-host
echo ""
echo " ___________________________ "
echo "|                           |"
echo "|    ICON_schredder v0.9    |" 
echo "|     Author: TerraCuda     |"
echo "|___________________________|"
echo ""

                 #Variables
$count = 12 #how many files will be created
$path = (Get-Item -Path ".\").FullName
$target = Get-ChildItem $path\*.exe -Exclude "*_n.exe", "ResourceHacker.exe"
$targets = $target -replace '.exe',''


Start-Sleep -m 70


for ($i=0; $i -lt $count; $i++)
{
                 # replace the version resource in the target file and compose the new one.

$newtarget = "$($targets)_$($i)_n.exe"
.\ResourceHacker.exe -open $target -save $newtarget -action delete -mask "ICONGROUP,,"


echo "File $newtarget has been created"

Start-Sleep -m 70

}


exit