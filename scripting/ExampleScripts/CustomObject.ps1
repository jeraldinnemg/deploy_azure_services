$frase1 = @("mami","bebe","princess","mami")
$frase2 = @("yo quiero","yo puedo","yo vengo a","voy a")
$frase3 = @("encendelte","amalte","ligar","jugar")
$frase4 = @("suave","lento","rapido","fuerte")
$frase5 = @("hasta que salga el sol","toda la noche","hasta el amanecer","todo el dia")
$frase6 = @("sin anestesia","sin compromiso","feis to feis","sin miedo")

$frases = [PSCustomObject]@{
    Frase1 = $frase1
    Frase2 = $frase2
    Frase3 = $frase3
    Frase4 = $frase4
    Frase5 = $frase5
    Frase6 = $frase6
}

$frases.Frase1
$frases.Frase2
$frases.Frase3
$frases.Frase4
$frases.Frase5
$frases.Frase6