#Existen muchas maneras de hacer un script.
#Todas son válidas, siempre y cuando el script o demore demasiado en correr.
#Inicializamos los arrays
#$frase1 = @("mami","bebe","princess","mami")
#$frase2 = @("yo quiero","yo puedo","yo vengo a","voy a")
#$frase3 = @("encendelte","amalte","ligar","jugar")
#$frase4 = @("suave","lento","rapido","fuerte")
#$frase5 = @("hasta que salga el sol","toda la noche","hasta el amanecer","todo el dia")
#$frase6 = @("sin anestesia","sin compromiso","feis to feis","sin miedo")
#Para comentar o des-comentar muchas lineas al mismo tiempo, prueben hacer Ctrl+Alt+Cursor Abajo y escriban o borren.

#This only works while executing the script, it won't work on IDE
#$currentPath = $PSScriptRoot
#Modifiquen la ruta manualmente a la ruta en la que esté el csv
$currentPath = "c:\amasciotta\Academy\ExampleScripts"
$reggaeton_csv_file = "reggaeton.csv"
#Esto: 
$pathToFile = $currentPath + "\" + $reggaeton_csv_file
#Es lo mismo que esto:
$pathToFile = "$currentPath\$reggaeton_csv_file"
#Importamos un CSV
$csv = Get-Content $pathToFile | ConvertFrom-Csv

#Mostramos el CSV como tabla:
$csv | format-table

#obtenemos un item random de cada array
$rndFrase1 = $csv.frase1 | Get-Random
$rndFrase2 = $csv.frase2 | Get-Random
$rndFrase3 = $csv.frase3 | Get-Random
$rndFrase4 = $csv.frase4 | Get-Random
$rndFrase5 = $csv.frase5 | Get-Random
$rndFrase6 = $csv.frase6 | Get-Random

#Mostramos las variables
Write-Output "$rndFrase1 $rndFrase2 $rndFrase3 $rndFrase4 $rndFrase5 $rndFrase6"
#Atentos, si usan comillas simples, no se reemplazan las variables
#Ejemplo:
Write-Output '$($rndFrase1) $rndFrase2 $rndFrase3 $rndFrase4 $rndFrase5 $rndFrase6'
#Si tuvieran que escribir comillas, hay que 'escaparlas'
#Estas cosas se conocen en lenguajes de programacion como caracteres de escape
#En algunos lenguajes es la barra invertida (\)
#En powershell es el acento invertido `
#Por ejemplo:
Write-Output "`"$rndFrase1`" $rndFrase2 $rndFrase3 $rndFrase4 $rndFrase5 $rndFrase6"
#Quoting rules 
#https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-7.3