#Author:  https://github.com/terracuda/workpow
  
                #Welcome message
clear-host
echo ""
echo " ___________________________ "
echo "|                           |"
echo "|      JPG_resizer v1.1     |" 
echo "|     Author: TerraCuda     |"
echo "|___________________________|"
echo ""



                 #Variables
$count = 25 #how many new images will be created
$path = (Get-Item -Path ".\").FullName
$target = Get-ChildItem $path\source.jpg
Import-Module $path\Resize-Image.psm1 

for ($i=0; $i -lt $count; $i++)
{

                 # Generate new file version
$scaleh = Get-Random -Minimum 1 -Maximum 1080
$scalew = Get-Random -Minimum 1 -Maximum 1920



$newimage = "$($target)_$($i).jpg"

Resize-Image -InputFile $target -OutputFile $newimage -Width $scalew -Height $scaleh
# Resize-Image -InputFile $target -Width 400 -Height 200 -Display -scale 40 
}

exit