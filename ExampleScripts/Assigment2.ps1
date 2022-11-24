#Get childitem lee items dentro de una carpeta x
#cuenta archivos bmp de parametro $p
$LogFile = "C:\repos\Assignments\bmps\run.log"
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


function ContarBmps ($p)
{
    $count = $(Get-ChildItem -Path $p -include *.bmp -Recurse).count
    return $count
}
#cuenta archivos bmp de parametro $p
function ContarArchivos ($p,$x)
{
    $count = $(Get-ChildItem -Path $p -include $x -Recurse).count
    return $count
}

$path = "C:\repos\Assignments" 
$archivos = Get-ChildItem -Path $path -include *.bmp -Recurse
$pathDestino = "C:\temp\prueba" 
$cantidadArchivos = $archivos.count


Write-Output "Cantidad de bmps: $cantidadArchivos"

foreach($archivo in $archivos)
{
    try{
        WriteLog "Intentando copiar $archivo.name"
        copy-item $archivo -Destination $pathDestino
        WriteLog "Success"
    }

    catch {
        Write-Output'Error copiando archivos!'
        Write-Out $_
    }

}