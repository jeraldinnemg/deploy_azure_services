#Playing with APIs
#Pasos genericos
$apiURL = "https://api.coindesk.com/v1/bpi/currentprice.json"

#Metodo simple
$result = Invoke-RestMethod -Uri $apiURL

#Metodo complejo pero mas versatil
$webRequest = $(Invoke-WebRequest -uri $apiURL).content | ConvertFrom-Json


#Procesando datos obtenidos de API de Coindesk
$precioUSD = $webRequest.bpi.USD.rate
$precioGBP = $webRequest.bpi.GBP.rate
$precioEUR = $webRequest.bpi.EUR.rate
Write-Output "Valor del Bitcoin en principales monedas:"
Write-Output "Valor del Bitcoin: `nUSD: $precioUSD`nEUR: $precioEUR`nGBP: $precioGBP"

#Usando API de Binance
#La URL siguiente trae muchos datos
#$urlBinance = "https://api2.binance.com/api/v3/ticker/24hr"
#Filtramos desde la llamada a la API para que traiga solo symbol=ETHBUSD
$urlBinance = "https://api2.binance.com/api/v3/ticker/24hr?symbol=ETHBUSD"

#Llamamos a la API y convertimos el contenido json a un objeto y lo asignamos a binanceRequest
$binanceRequest = $(Invoke-WebRequest -uri $urlBinance).content | ConvertFrom-Json

#Como trae muchos decimales, usamos una funcion de .NET para redondear con 2 decimales
$precioETH = [math]::Round($binanceRequest.lastPrice,2)

#Mostramos el valor
Write-Output "ETH(BUSD): $precioETH"