param(
  [ValidateSet("create", "delete", ErrorMessage = "Action is not valid")]
  [Parameter(Mandatory)][string]$Action,
  # el usuario tiene que poder crear o borrar uno o más recursos
  [switch]$ResourceGroup,
  [switch]$NetworkSecurityGroup,
  [switch]$VirtualNetwork,
  [switch]$Subnet,
  [switch]$KeyVault,
  [switch]$StorageAccount,
  [switch]$AppServicePlan,
  [switch]$AzureFunctionApp,
  [switch]$all,
  [string]$ResourceGroupName,
  [string]$NetworkSecurityGroupName,
  [string]$VirtualNetworkName,
  [string]$SubnetName,
  [string]$KeyVaultName,
  [string]$StorageAccountName,
  [string]$AppServicePlanName,
  [string]$AzureFunctionAppName
)
function Write-LogCustom {
  param (
    [Parameter(Mandatory)][string]$Message
  )
  $logPath = ".\log"
  $logName = "run"
  $logFile = "$logPath\$logName.log"
  # si no existe el directorio, lo creo
  if (!(Test-Path -Path $logPath)) {
    # Out-Null no me avisa por la terminal que crea la carpeta
    New-Item $logPath -Type Directory | Out-Null
  }
  try {
    $dateTime = Get-Date -Format 'MM-dd-yy HH:mm:ss'
    $logToWrite = $dateTime + ": " + $Message
    # Add-Content creates the file so there's no need to check if the file already exists
    Add-Content -Path $logFile -Value $logToWrite
  }
  catch {
    $dateTime = Get-Date -Format 'MM-dd-yy HH:mm:ss'
    $logToWrite = $dateTime + ": Failed to give a message"
    Add-Content -Path $logFile -Value $logToWrite
  }
}
function Validate-ResourceName {
  # Valida que el nombre que ingresa el usuario respete la EY convention
  # Mejorar: solo STA debería ingresarse en minúsculas
  param(
    [Parameter(Mandatory)]$ResourceName
  )
  $ValidationStatus = $true
  $LengthExpected = 17
  $OnlyAlphanumericRegex = '^[a-zA-Z0-9]+$'
  $CloudProviderHash = @{
    # "am" = "Amazon"
    "az" = "Azure"
    # "gc" = "Google Cloud"
  }
  $LocationHash = @{
    "use" = "East US"
    "ue2" = "East US 2"
    "usc" = "Central US"
    "usn" = "North Central US"
    "uss" = "South Central US"
    "usw" = "West Central US"
    "uwu" = "West US"
    "uw2" = "West US 2"
    "ugn" = "US Gov Non-Regional"
    "ugv" = "US Gov Virginia"
    "ugi" = "US Gov IOWA"
    "uga" = "US Gov Arizona"
    "ugt" = "US Gov Texas"
    "ude" = "US DOD East"
    "udc" = "US DOD Central"
    "cae" = "Canada East"
    "cac" = "Canada Central"
    "brs" = "Brazil South"
    "eun" = "North Europe"
    "euw" = "West Europe"
    "ukw" = "UK West"
    "uks" = "UK South"
    "gec" = "Germany Central"
    "gen" = "Germany Northeast"
    "gno" = "Germany North"
    "gwc" = "Germany West Central"
    "frc" = "France Central"
    "frs" = "France South"
    "aps" = "Southeast Asia"
    "ape" = "East Asia"
    "aue" = "Australia East"
    "aus" = "Australia Southeast"
    "ac1" = "Australia Central 1"
    "ac2" = "Australia Central 2"
    "cne" = "China East"
    "cnn" = "China North"
    "inc" = "Central India"
    "inw" = "West India"
    "ins" = "South India"
    "jpe" = "Japan East"
    "jpw" = "Japan West"
    "koc" = "Korea Central"
    "kos" = "Korea South"
  }
  $EnvironmentHash = @{
    "c" = "poc"
    "d" = "dev"
    "q" = "qa"
    "u" = "uat"
    "f" = "perf"
    "e" = "demo"
    "x" = "staging"
    "p" = "prod"
    "g" = "training"
    "r" = "dr"
  }
  $ResourceTypeHash = @{
    "rsg" = "Resource Group"
    "nsg" = "Network Security Group"
    "vnt" = "Virtual Network"
    "sbn" = "Subnet"
    "akv" = "Key Vault"
    "sta" = "Storage Account"
    "asp" = "App Service Plan"
    "azf" = "Azure Function App"
    # Azure has more resources
  }
  # Valida la cantidad de caracteres
  if ($ResourceName.Length -eq $LengthExpected){
    # Valida que no hayan caracteres especiales
    if($ResourceName -match $OnlyAlphanumericRegex){
      # Valida cada porción del string
      $CloudProvider = $ResourceName.Substring(0,2)
      $Location = $ResourceName.Substring(2,3)
      $Environment = $ResourceName.Substring(5,1)
      # $DeploymentID = $ResourceName.Substring(6,6)
      $ResourceType = $ResourceName.Substring(12,3)
      # $Sequence = $ResourceName.Substring(15,2)
      if($CloudProviderHash.ContainsKey($CloudProvider)) { 
        Write-LogCustom -Message "Cloud Provider $($CloudProviderHash.$CloudProvider) is valid" 
      }
      else { 
        Write-LogCustom -Message "Cloud Provider $CloudProvider is not valid"
        $ValidationStatus = $false
      }
      if($LocationHash.ContainsKey($Location)) {
        Write-LogCustom -Message "Location $($LocationHash.$Location) is valid" 
      }
      else { 
        Write-LogCustom -Message "Location $Location is not valid"
        $ValidationStatus = $false
      }
      if($EnvironmentHash.ContainsKey($Environment)) {
        Write-LogCustom -Message "Environment $($EnvironmentHash.$Environment) is valid"
      }
      else {
        Write-LogCustom -Message "Environment $Environment is not valid"
        $ValidationStatus = $false
      }
      if($ResourceTypeHash.ContainsKey($ResourceType)) {
        Write-LogCustom -Message "Resource Type $($ResourceTypeHash.$ResourceType) is valid" 
      }
      else {
        Write-LogCustom -Message "Resource Type $ResourceType is not valid"
        $ValidationStatus = $false
      }
    }
    else{
      Write-LogCustom -Message "Only alphanumeric characters are accepted"
      $ValidationStatus = $false
    }
  }
  else{
    Write-LogCustom -Message  "The name length is $($ResourceName.Length) while it's expected $LengthExpected"
    $ValidationStatus = $false
  }
  return $ValidationStatus
}
function Create-ResourceName {
  # si el usuario no ingresó un name, asigna un nombre con cloud provider, location, environment definidos, type parametrizado, ID y sequence random
  param(
    [ValidateSet("Azure", "Google Cloud")][string]$CloudProvider = "Azure",
    [ValidateSet("East US", "East US 2", "Central US", "North Central US", "South Central US", "West Central US", "West US", "West US 2", "US Gov Non-Regional", "US Gov Virginia", "US Gov IOWA", "US Gov Arizona", "US Gov Texas", "US DOD East", "US DOD Central", "Canada East", "Canada Central", "Brazil South", "North Europe", "West Europe", "UK West", "UK South", "Germany Central", "Germany Northeast", "Germany North", "Germany West Central", "France Central", "France South", "Southeast Asia", "East Asia", "Australia East", "Australia Southeast", "Australia Central 1", "Australia Central 2", "China East", "China North", "Central India", "West India", "South India", "Japan East", "Japan West", "Korea Central", "Korea South")][string]$Location = "East US",
    [ValidateSet("poc", "dev", "qa", "uat", "perf", "demo", "staging", "prod", "training", "dr")][string]$Environment = "dev",
    [Parameter(Mandatory)][string]$ResourceType
  )
  try {
    $CloudProviderHash = @{
      # "Amazon"       = "am"
      "Azure"        = "az"
      # "Google Cloud" = "gc"
    }
    $CloudProviderCode = $CloudProviderHash.$CloudProvider
    $LocationHash = @{
      "East US"              = "use"
      "East US 2"            = "ue2"
      "Central US"           = "usc"
      "North Central US"     = "usn"
      "South Central US"     = "uss"
      "West Central US"      = "usw"
      "West US"              =	"uwu"
      "West US 2"            = "uw2"
      "US Gov Non-Regional"  =	"ugn"
      "US Gov Virginia"      = "ugv"
      "US Gov IOWA"          =	"ugi"
      "US Gov Arizona"       =	"uga"
      "US Gov Texas"         =	"ugt"
      "US DOD East"          =	"ude"
      "US DOD Central"       =	"udc"
      "Canada East"          =	"cae"
      "Canada Central"       =	"cac"
      "Brazil South"         =	"brs"
      "North Europe"         =	"eun"
      "West Europe"          =	"euw"
      "UK West"              =	"ukw"
      "UK South"             =	"uks"
      "Germany Central"      =	"gec"
      "Germany Northeast"    =	"gen"
      "Germany North"        =	"gno"
      "Germany West Central"	=	"gwc"
      "France Central"       =	"frc"
      "France South"         =	"frs"
      "Southeast Asia"       =	"aps"
      "East Asia"            =	"ape"
      "Australia East"       =	"aue"
      "Australia Southeast"  =	"aus"
      "Australia Central 1"  =	"ac1"
      "Australia Central 2"  =	"ac2"
      "China East"           =	"cne"
      "China North"          =	"cnn"
      "Central India"        =	"inc"
      "West India"           =	"inw"
      "South India"          =	"ins"
      "Japan East"           =	"jpe"
      "Japan West"           =	"jpw"
      "Korea Central"        =	"koc"
      "Korea South"          =	"kos"
    }
    $LocationCode = $LocationHash.$Location
    $EnvironmentHash = @{
      "poc"      = "c"
      "dev"      =	"d"
      "qa"       = "q"
      "uat"      = "u"
      "perf"     = "f"
      "demo"     = "e"
      "staging"  =	"x"
      "prod"     =	"p"
      "training" = "g"
      "dr"       = "r"
    }
    $EnvironmentCode = $EnvironmentHash.$Environment
    $letters = 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
    $numbers = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    $DeploymentID = $letters, $numbers | Get-Random -Count 6
    $ResourceTypeHash = @{
      "Resource Group"         = "rsg"
      "Network Security Group" = "nsg"
      "Virtual Network"        = "vnt"
      "Subnet"                 = "sbn"
      "Key Vault"              = "akv"
      "Storage Account"        = "sta"
      "App Service Plan"       = "asp"
      "Azure Function App"     = "azf"
      # Azure has more resources
    }
    $ResourceTypeCode = $ResourceTypeHash.$ResourceType
    $SequenceCode = $letters, $numbers | Get-Random -Count 2
    # si la sequence es 00, vuelve a buscar otro
    while($SequenceCode -eq "00"){
        $SequenceCode = $letters, $numbers | Get-Random -Count 2
    }
    if ($ResourceTypeCode -eq "sta") {
        $defaultName = ($CloudProviderCode + $LocationCode + $EnvironmentCode + $DeploymentID + $ResourceTypeCode + $SequenceCode).Replace(" ", "")
    }
    else {
        $defaultName = ($CloudProviderCode + $LocationCode + $EnvironmentCode + $DeploymentID + $ResourceTypeCode + $SequenceCode).Replace(" ", "").ToUpper()
    }
    return $defaultName
  }
  catch {
    Write-LogCustom -Message "Failed to create resource name"
  }
}
function Validate-ResourceExists {
  # devuelve true si no hay un recurso en az con el mismo nombre, sino devuelve false
  param(
    [ValidateSet("rsg", "rsc")]
    [Parameter(Mandatory)][string]$RsgOrRsc,
    [Parameter(Mandatory)][string]$ResourceName
  )
  try{
    # si no estoy conectado, lo hago
    # Connect-AzAccount | Out-Null
    $ValidationStatus = $true
    if($RsgOrRsc -eq "rsg"){
      $existingRsg = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceName }
      if(!$existingRsg){
        $ValidationStatus = $false
      }
    }
    elseif($RsgOrRsc -eq "rsc"){
      $existingRsc = Get-AzResource | Where-Object { $_.Name -eq $ResourceName }
      if(!$existingRsc){
        $ValidationStatus = $false
      }
    }
    return $ValidationStatus
  }
  catch{
    Write-LogCustom -Message "Failed to validate if the resource exists in Azure"
  }
}
function Create-AllResources{

}
function Create-ResourceGroup {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    $location = "eastus"
  )
  if (!(Validate-ResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupName)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $location
  }
}
function Create-Resource {
  #pasar por parametro el resource, resource name y resource group name
  try {
    # concatenar if de acuerdo a las dependencias (Validar el uso correcto de los recursos. Por ejemplo, para deployar una Subnet, siempre deberá existir una Virtual Network)
    # crear dentro del resource group creado o reciclado
    if ($StorageAccount) {
      $ResourceGroupName = Create-ResourceGroup
      $templateFilePath = ".\arm\storageaccount.json"
      # $templateParametersFilePath = ".\arm\storageaccount.parameters.json"
      $existingRsc = Get-AzResource | Where-Object { $_.Name -eq $StorageAccountName }
      if (!$existingRsc) {
        if ($null -eq $StorageAccountName) {
          Create-ResourceName -ResourceType "Storage Account"
        }
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -TemplateFile $templateFilePath
        # Validar que el recurso se haya creado en Azure según corresponda
        Write-LogCustom -Message "Resource $StorageAccountName created successfully"
      }
      else {
        Write-LogCustom "Resource $StorageAccountName already exists"
      }
    }
    if ($KeyVault -eq $true) {
      
    }
    if ($RNetworkSecurityGroup -eq $true) {
      
    }
    if ($VirtualNetwork -eq $true) {
      
    }
    if ($Subnet -eq $true) {
      
    }
    if ($AppServicePlan -eq $true) {
      
    }
    if ($AzureFunctionApp -eq $true) {
      
    }
    # iterar por cada resource para hacerlo dinámico
  }
  catch {
    Write-LogCustom -Message "Failed to create resource"
  }
}
function Delete-All {
  try{
    # buscar el rsg
    $existingResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
    if ($existingResourceGroup) {
      Remove-AzResourceGroup -Name $ResourceGroupName -Force
      Start-Sleep -Seconds 5
      $existingResourceGroup2 = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
      if (!$existingResourceGroup2) {
        Write-LogCustom -Message "All resources were successfully deleted"
      }
      else {
        Write-LogCustom -Message "Failed to delete all resources"
      }
    }
  }
  catch{
    Write-LogCustom -Message "Failed to find resources"
  }
}
function Delete-Resource {
  # todo va a estar dentro de un mismo resource group
  param(
    [Parameter(Mandatory = $null)][string]$ResourceGroupName,
    [Parameter(Mandatory = $null)][string]$NetworkSecurityGroupName,
    [Parameter(Mandatory = $null)][string]$VirtualNetworkName,
    [Parameter(Mandatory = $null)][string]$SubnetName,
    [Parameter(Mandatory = $null)][string]$KeyVaultName,
    [Parameter(Mandatory = $null)][string]$StorageAccountName,
    [Parameter(Mandatory = $null)][string]$AppServicePlanName,
    [Parameter(Mandatory = $null)][string]$AzureFunctionAppName
  )
  try {
    # encontrar el rsg para poder borrar cada recurso
    $existingResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
    if ($null -eq $existingResourceGroup) {
      Write-LogCustom -Message "There is no Resource Group named $ResourceGroupName"
    }
    else {
      if ($NetworkSecurityGroupName) {
        $existingResource = Get-AzResource | Where-Object { $_.Name -eq $NetworkSecurityGroupName }
        if ($null -eq $existingResource) {
          Write-LogCustom -Message "There is no Network Security Group named $NetworkSecurityGroupName"
        }
        else {
          Remove-AzResource `
            -ResourceGroupName $ResourceGroupName `
            -ResourceName $NetworkSecurityGroupName `
            -ResourceType Microsoft.Network/networkSecurityGroups -Force
          # Validar que el recurso se haya borrado en Azure
          Start-Sleep -Seconds 5
          $existingResource2 = Get-AzResource | Where-Object { $_.Name -eq $NetworkSecurityGroupName }
          if (!$existingResource2) {
            Write-LogCustom -Message "Network Security Group $NetworkSecurityGroupName deleted successfully"
          }
          else {
            Write-LogCustom -Message "Failed to delete Network Security Group $NetworkSecurityGroupName"
          }
        }
      }
      if ($VirtualNetworkName) {
        $existingResource = Get-AzResource | Where-Object { $_.Name -eq $VirtualNetworkName }
        if ($null -eq $existingResource) {
          Write-LogCustom -Message "There is no Virtual Network named $VirtualNetworkName"
        }
        else { 
          Remove-AzResource `
            -ResourceGroupName $ResourceGroupName `
            -ResourceName $VirtualNetworkName `
            -ResourceType Microsoft.Network/virtualNetworks -Force
          Start-Sleep -Seconds 5
          $existingResource2 = Get-AzResource | Where-Object { $_.Name -eq $VirtualNetworkName }
          if (!$existingResource2) {
            Write-LogCustom -Message "Virtual Network $VirtualNetworkName deleted successfully"
          }
          else {
            Write-LogCustom -Message "Failed to delete Virtual Network $NetworkSecurityGroupName"
          }
        }
      }
      if ($SubnetName) {
        $existingResource = Get-AzResource | Where-Object { $_.Name -eq $SubnetName }
        if ($null -eq $existingResource) {
          Write-LogCustom -Message "There is no Subnet named $SubnetName"
        }
        else { 
          Remove-AzResource `
            -ResourceGroupName $ResourceGroupName `
            -ResourceName $SubnetName `
            -ResourceType Microsoft.Network/virtualNetworks -Force
          Start-Sleep -Seconds 5
          $existingResource2 = Get-AzResource | Where-Object { $_.Name -eq $SubnetName }
          if (!$existingResource2) {
            Write-LogCustom -Message "Subnet $SubnetName deleted successfully"
          }
          else {
            Write-LogCustom -Message "Failed to delete Subnet $SubnetName"
          }
        }
      }
      if ($KeyVaultName) {
        $existingResource = Get-AzResource | Where-Object { $_.Name -eq $KeyVaultName }
        if ($null -eq $existingResource) {
          Write-LogCustom -Message "There is no Key Vault named $KeyVaultName"
        }
        else {
          Remove-AzResource `
            -ResourceGroupName $ResourceGroupName `
            -ResourceName $KeyVaultName `
            -ResourceType Microsoft.KeyVault/vaults -Force
          Start-Sleep -Seconds 5
          $existingResource2 = Get-AzResource | Where-Object { $_.Name -eq $KeyVaultName }
          if (!$existingResource2) {
            Write-LogCustom -Message "Key Vault $KeyVaultName deleted successfully"
          }
          else {
            Write-LogCustom -Message "Failed to delete Key Vault $KeyVaultName"
          }
        }
      }
      if ($StorageAccountName) {
        $existingResource = Get-AzResource | Where-Object { $_.Name -eq $StorageAccountName }
        if ($null -eq $existingResource) {
          Write-LogCustom -Message "There is no Storage Account named $StorageAccountName"
        }
        else {
          Remove-AzResource `
            -ResourceGroupName $ResourceGroupName `
            -ResourceName $StorageAccountName `
            -ResourceType Microsoft.Storage/storageAccounts -Force
          Start-Sleep -Seconds 5
          $existingResource2 = Get-AzResource | Where-Object { $_.Name -eq $StorageAccountName }
          if (!$existingResource2) {
            Write-LogCustom -Message "Storage Account $StorageAccountName deleted successfully"
          }
          else {
            Write-LogCustom -Message "Failed to delete Storage Account $StorageAccountName"
          }
        }
      }
      if ($AppServicePlanName) {
        $existingResource = Get-AzResource | Where-Object { $_.Name -eq $AppServicePlanName }
        if ($null -eq $existingResource) {
          Write-LogCustom -Message "There is no App Service Plan named $AppServicePlanName"
        }
        else {
          Remove-AzResource `
            -ResourceGroupName $ResourceGroupName `
            -ResourceName $AppServicePlanName `
            -ResourceType Microsoft.Web/serverfarms -Force
          Start-Sleep -Seconds 5
          $existingResource2 = Get-AzResource | Where-Object { $_.Name -eq $AppServicePlanName }
          if (!$existingResource2) {
            Write-LogCustom -Message "App Service Plan $AppServicePlanName deleted successfully"
          }
          else {
            Write-LogCustom -Message "Failed to delete App Service Plan $AppServicePlanName"
          }
        }
      }
      if ($AzureFunctionAppName) {
        $existingResource = Get-AzResource | Where-Object { $_.Name -eq $AzureFunctionAppName }
        if ($null -eq $existingResource) {
          Write-LogCustom -Message "There is no Azure Function App named $AzureFunctionAppName"
        }
        else {
          Remove-AzResource `
            -ResourceGroupName $ResourceGroupName `
            -ResourceName $AzureFunctionAppName `
            -ResourceType Microsoft.Web/sites -Force
          Start-Sleep -Seconds 5
          $existingResource2 = Get-AzResource | Where-Object { $_.Name -eq $AzureFunctionAppName }
          if (!$existingResource2) {
            Write-LogCustom -Message "Azure Function App $AzureFunctionAppName deleted successfully"
          }
          else {
            Write-LogCustom -Message "Failed to delete Azure Function App $AzureFunctionAppName"
          }
        }
      }
      if ($ResourceGroupName -and $null -eq $NetworkSecurityGroupName -and $null -eq $VirtualNetworkName -and $null -eq $SubnetName -and $null -eq $KeyVaultName -and $null -eq $StorageAccountName -and $null -eq $AppServicePlanName -and $null -eq $AzureFunctionAppName) {
        Remove-AzResourceGroup -Name $ResourceGroupName -Force
        Start-Sleep -Seconds 5
        $existingResourceGroup2 = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
        if (!$existingResourceGroup2) {
          Write-LogCustom -Message "Resource Group $ResourceGroupName deleted successfully"
        }
        else {
          Write-LogCustom -Message "Failed to delete Resource Group $ResourceGroupName"
        }
      }
    }
  }
  catch {
    Write-LogCustom -Message "Failed to delete resource"
  }
}
# Inicio del script
# Con loggear al principio alcanza?
Connect-AzAccount | Out-Null
if($Action -eq "create"){
  # Crear todo (switch parameters false)
  if(!$ResourceGroup -and !$NetworkSecurityGroup -and !$VirtualNetwork -and !$Subnet -and !$KeyVault -and !$StorageAccount -and !$AppServicePlan -and !$AzureFunctionApp){
    Create-All
  }
  # Valido que recibí un nombre por parámetro, que respete la EY naming convention o voy a genear alguno y lo voy a guardar
  if($ResourceGroupName){
    if(Validate-ResourceName -ResourceName $ResourceGroupName) {
      Write-LogCustom -Message "The name $ResourceGroupName respects the EY naming convention"
    }else{
      Write-LogCustom -Message "The name $ResourceGroupName is not valid according to EY naming convention"
      $ResourceGroupName = Create-ResourceName -ResourceType "Resource group"
      Write-LogCustom -Message "New resource name $ResourceGroupName created successfully"
    }
  }else{
    Write-LogCustom -Message "The user did not define a name"
    $ResourceGroupName = Create-ResourceName -ResourceType "Resource group"
    Write-LogCustom -Message "New resource name $ResourceGroupName created successfully"
  }
  $global:ResourceGroupNameGlobal = $ResourceGroupName
  Create-ResourceGroup -ResourceGroupName $ResourceGroupName
  # validar que se haya creado
  if(Validate-ResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupName){
    Write-LogCustom -Message "Resource group $ResourceGroupName created successfully"
  }
  else{
    Write-LogCustom -Message "Failed to delete $ResourceGroupName created successfully"
  }
  # si no selecciono solo rsg, creo el/los recursos dentro del mismo rsg (var global?)
  #  primero tener el nombre
  <#
  # Valido que el nombre elegido o creado, esté disponible en Azure o lo voy a recrear hasta que no exista uno igual
  while(Validate-ResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupName){
    Write-LogCustom -Message "The name $ResourceGroupName is not available in Azure"
    $ResourceGroupName = Create-ResourceName -ResourceType "Resource group"
    Write-LogCustom -Message "New resource name $ResourceGroupName created successfully"
  }
  #>
  #  tener en cuenta dependencias
  #  crear
  #  validar que se hayan creado
  #  iterar?
}
elseif($Action -eq "delete"){
  if($ResourceGroupNameGlobal){
    Remove-AzResourceGroup -Name $ResourceGroupNameGlobal -Force
  }
  elseif($all){
    #sasha function
  }
  else{
    # delete -all
  }
  # borrar todos nulos los string parameters
  # borrar cada recurso dentro del mismo rsg
  #  validar que exista
  Write-LogCustom -Message "Starting deletion"
  #  borrar
  #  validar que se hayan borrado
  #  iterar?
}

function Show-ExportResourceIds {
  # Obtener una lista de todos los recursos de Azure
  $resources = Get-AzureRmResource

  # Crear una lista para almacenar los recursos ID generados o borrados
  $resourceIds = @()

  # Añadir los recursos ID a la lista
  foreach ($resource in $resources) {
    $resourceIds += $resource.ResourceId
  }

  # Mostrar los recursos ID
  $resourceIds

  # Exportar los recursos ID a un archivo de texto
  $resourceIds | Out-File -FilePath 'resource_ids.txt'
}

# Ejecutar la función
Show-ExportResourceIds
