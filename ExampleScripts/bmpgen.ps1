#This only works while executing the script, it won't work on IDE
#$currentPath = $PSScriptRoot
$currentPath = "c:\amasciotta\Academy\ExampleScripts\bmpgen"
$amountOfBmps = 150
$xResolution = 320
$yResolution = 240
$folders = 10
$folderList = @()

#Creation of Folders
Write-Output "Creating $folders folders in $currentPath"
Write-Progress -Activity "Creating Folders..." -Status "0% complete" -PercentComplete 0
for($i = 1; $i -le $folders ; $i++)
{
  $percentComplete = $i * 100 / $folders
  Write-Progress -Activity "Creating Folders..." -Status "$percentComplete complete" -PercentComplete $percentComplete
  $folderToCreate = "$currentPath\$i"
  Write-Output "Creating Folder $folderToCreate"
  mkdir $folderToCreate
  $folderList+=$folderToCreate
}

Write-Output "Generating $amountOfBmps BMPs of $xResolution x $yResolution in $folders different folders randomly."
Write-Progress -Activity "Generating BMPs..." -Status "$0 complete" -PercentComplete 0
for ($n = 1; $n -le $amountOfBmps; $n++)
{
  $percentComplete = $n * 100 / $amountOfBmps
  Write-Progress -Activity "Generating BMPs..." -Status "$percentComplete complete" -PercentComplete $percentComplete
  [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $bmp = New-Object System.Drawing.Bitmap($xResolution, $yResolution)
    $rndx = Get-Random -Minimum 1 -Maximum 300
    $rndy = Get-Random -Minimum 1 -Maximum 200
    Write-Output "$rndx , $rndy"
    for ($i = $rndx; $i -lt $xResolution; $i++)
    {
       for ($j = $rndy; $j -lt $yResolution; $j += 2)
       {
         $bmp.SetPixel($i, $j, 'Red')
         $bmp.SetPixel($i, $j , [System.Drawing.Color]::FromArgb(0, 100, 200))
       }
    }
    Write-Output "$currentPath\bmp$n.bmp"
    #Simple method
    #$bmp.Save("$currentFolder\bmp$n.bmp")
    #More complex method
    $rndFolder = $folderList | Get-Random
    $bmp.Save("$rndFolder\bmp$n.bmp")
}
