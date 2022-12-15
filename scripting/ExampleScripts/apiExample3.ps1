#Lee una lista de nombres de un archivo de texto, escoge aleatoriamente y cuenta la cantidad de letras "A", 

#Definimos URLs a utilizar
$req= $(Invoke-WebRequest " https://github.com/olea/lemarios/blob/master/nombres-propios-es.txt").content- | Sort-Object{Get-Random}

#Inicialización de contadores
$countA= 0
$countL=0
$count3= 0

#Recorremos todos los nombres en la lista
foreach($nombre in $req)
{
    if($nombre -match A*) -and ($countA -le 4) ; then
    Write-Output "Nombre: $nombre"
    $countA++
    $gender = $( $(Invoke-WebRequest -Uri "$urlGenderize/?name=$nombre").content | ConvertFrom-Json).gender
    $nation = $( $(Invoke-WebRequest -Uri "$urlNationalize/?name=$nombre").content | ConvertFrom-Json).country[0].country_id
    Write-Output "Gender: $gender"
    Write-Output "Nation: $nation"

    elif ($nombre -match L*) -and ($countA -le 4) ; then
    Write-Output "Nombre: $nombre"
    $countL++
    $gender = $( $(Invoke-WebRequest -Uri "$urlGenderize/?name=$nombre").content | ConvertFrom-Json).gender
    $nation = $( $(Invoke-WebRequest -Uri "$urlNationalize/?name=$nombre").content | ConvertFrom-Json).country[0].country_id
    Write-Output "Gender: $gender"
    Write-Output "Nation: $nation"

    elif ($nombre -ne A*) -and ($nombre -ne L*) -and ($count3 -le 4) ; then
    Write-Output "Nombre: $nombre"
    $count3++
    $gender = $( $(Invoke-WebRequest -Uri "$urlGenderize/?name=$nombre").content | ConvertFrom-Json).gender
    $nation = $( $(Invoke-WebRequest -Uri "$urlNationalize/?name=$nombre").content | ConvertFrom-Json).country[0].country_id
    Write-Output "Gender: $gender"
    Write-Output "Nation: $nation"
}    

