#Playing with apis

#$apiUrl = "https://api.coindesk.com/v1/bpi/currentprice.json"
#$result = Invoke-RestMethod -uri $apiUrl

#$webRequest = $(Invoke-WebRequest -uri $apiUrl).content | ConvertFrom-Json

# $precioUSD = $webRequest.bpi.USD.rate
# $precioGBP = $webRequest.bpi.GBP.rate
# $precioEUR = $webRequest.bpi.EUR.rate

# Write-Output "Valor del Bitcoin en pincipales monedas"
# Write-Output "Valor del Bitcoin: USD: $precioUSD EUR: $precioEUR GBP: $precioGBP"

$apiURL = "https://api.coindesk.com/v1/bpi/currentprice.json"

$result = Invoke-RestMethod -Uri $apiURL

$webRequest = $(Invoke-WebRequest -uri $apiURL).content | ConvertFrom-Json

$precioUSD = $webRequest.bpi.USD.rate

$precioGBP = $webRequest.bpi.GBP.rate

$precioEUR = $webRequest.bpi.EUR.rate


Write-Output "Valor del Bitcoin en principales monedas:"

Write-Output "Valor del Bitcoin: USD: $precioUSD EUR: $precioEUR GBP: $precioGBP"
