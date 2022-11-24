#get-childitem lee items dentro de una carpeta x

$LogFile = "C:\repos\acd-scripting\Assignments\run.log"
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

#Cuenta archivos bmp en parametro
function ContarBmps($p) {
    $count = $(Get-ChildItem -Path $p -include *.bmp -Recurse).count
    return $count
}

#Cuenta archivos de extensión $x en path $p

function ContarArchivos($p, $x){
    $count = $(Get-ChildItem -Path $p -include $x -Recurse).count
    return $count
}


#declaración de variables

$path = "C:\repos\acd-scripting\Assignments"
$archivos = Get-ChildItem -Path $path -Include *.bmp -Recurse
$cantidadArchivos = $archivos.count
$pathDestino = "C:\repos\prueba"

Write-Output "Cantidad de bmps: $cantidadArchivos"

#mover archivos a otra carpeta

foreach($archivo in $archivos) {
    try {
        WriteLog "Intentando copiar archivo $archivo.name"
        Copy-Item $archivo -Destination $pathDestino -ErrorAction Stop      
        WriteLog "Success"  
    }
    catch {
        Write-Output 'Error copiando archivos!'
        Write-Output $_ #
    }
}