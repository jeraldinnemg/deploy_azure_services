#Existen muchas maneras de hacer un script.
#Todas son válidas, siempre y cuando el script o demore demasiado en correr.
#Inicializamos los arrays
$frase1 = @("mami","bebe","princess","mami")
$frase2 = @("yo quiero","yo puedo","yo vengo a","voy a")
$frase3 = @("encendelte","amalte","ligar","jugar")
$frase4 = @("suave","lento","rapido","fuerte")
$frase5 = @("hasta que salga el sol","toda la noche","hasta el amanecer","todo el dia")
$frase6 = @("sin anestesia","sin compromiso","feis to feis","sin miedo")

#obtenemos un item random de cada array
$rndFrase1 = $frase1 | Get-Random
$rndFrase2 = $frase2 | Get-Random
$rndFrase3 = $frase3 | Get-Random
$rndFrase4 = $frase4 | Get-Random
$rndFrase5 = $frase5 | Get-Random
$rndFrase6 = $frase6 | Get-Random

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

#Comentario2