#Consigna:
#Mi hija estuvo jugando con la compu y me descontroló mi carpeta de fotos...
#No me acuerdo cuantas habian pero se que no eran 170, asi que seguramente duplicó algunas de las fotos...
#Aparte me gustaria que todas las fotos quedaran en una sola carpeta sin archivos repetidos…. ¿como podemos hacerlo??
#Lógica: 
#Obtener lista de archivos de path x de manera recursiva (Incluyendo sub folders), filtrando solo archivos .bmp
#Copiar lista obtenida a carpeta de destino (el copy-item por default ya hace overwrite)

$LogFile = "C:\amasciotta\code\acd-scripting\Assignments\run.log"
function WriteLog {
    param ( 
        [Parameter(Mandatory)] 
        [string]$Message 
    ) 
 
    try {
        $DateTime = Get-Date -Format 'MM-dd-yy HH:mm:ss'
        $LogToWrite = $DateTime + ": " + $Message
        Add-Content -Path $LogFile -Value $LogToWrite
        Write-Output $LogToWrite
    }
    catch { 
        Write-Error $_.Exception.Message 
    } 
}

#Get-ChildItem lee items dentro de una carpeta x

#Cuenta archivos bmp en parametro $p
function ContarBmps($p)
{
    $count = $(Get-ChildItem -Path $p -include *.bmp -Recurse).count
    return $count
}

#Cuenta archivos de extension $x en path $p
function ContarArchivos($p,$x)
{
    $count = $(Get-ChildItem -Path $p -include $x -Recurse).count
    return $count
}

#Reference documentation for functions:
#https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.3

$path = "C:\amasciotta\code\acd-scripting\Assignments"
$pathDestino = "c:\temp\prueba"
$archivos = Get-ChildItem -Path $path -include *.bmp -Recurse
$cantidadArchivos = $archivos.count

Write-Output "Cantidad de bmps: $cantidadArchivos"

foreach($archivo in $archivos)
{
    try
    {
        WriteLog "Intentando copiar $archivo.name"
        #parametro -whatif 
        copy-item $archivo -Destination $pathDestino -ErrorAction Stop
        WriteLog "Success"
    }
    catch 
    {
        Write-Output "Error copiando archivo $archivo.name"
        WriteLog $_
        #Write-Output $_
    }
}
