#Lee una lista de nombres de un archivo de texto y estima Gender y Nation
$lista = Get-Content .\listanombre.txt
#Definimos URLs a utilizar
$urlGenderize = "https://api.genderize.io"
$urlNationalize = "https://api.nationalize.io"
#Contador de Juanes en 0
$counter = 0

#Recorremos todos los nombres en la lista
foreach($nombre in $lista)
{
    Write-Output "Nombre: $nombre"
    #Llamamos a las APIs
    #invoke-webrequest es similar a curl
    #Resultado siempre esta en .content
    #Filtramos la URL por /?name=nombre
    #Como queremos leer la propiedad gender o country, le agregamos $() a toda la llamada.
    $gender = $( $(Invoke-WebRequest -Uri "$urlGenderize/?name=$nombre").content | ConvertFrom-Json).gender
    $nation = $( $(Invoke-WebRequest -Uri "$urlNationalize/?name=$nombre").content | ConvertFrom-Json).country[0].country_id
    Write-Output "Gender: $gender"
    Write-Output "Nation: $nation"
    if($nombre -match "Juan")
    {
        $counter++
    }
}
Write-Output "Encontramos $counter Juan en la lista"