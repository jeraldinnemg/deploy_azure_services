param(
  [ValidateSet("create", "delete", ErrorMessage = "Action is not valid")]
  [Parameter(Mandatory)][string]$Action,
  # The user should be able to create or delete one or more resources
  [switch]$ResourceGroup,
  [switch]$NetworkSecurityGroup,
  [switch]$VirtualNetwork,
  [switch]$Subnet,
  [switch]$KeyVault,
  [switch]$StorageAccount,
  [switch]$AppServicePlan,
  [switch]$AzureFunctionApp,
  [switch]$All,
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
  # If the directory does not exist, it is created
  if (!(Test-Path -Path $logPath)) {

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
  # Validates that the name entered by the user follows EY convention
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
  # Validates the number of characters
  if ($ResourceName.Length -eq $LengthExpected){
    # Validate that there are no special characters
    if($ResourceName -match $OnlyAlphanumericRegex){
      # Validates each portion of the string
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
  # If the user did not enter a name, it assigns a name with the cloud provider, location, environment defined, type parameterized, ID, and random sequence.
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
    # if the sequence is 00, look for another number.
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
  # Returns true if there is no resource in Azure with the same name, otherwise returns false.
  param(
    [ValidateSet("rsg", "rsc")]
    [Parameter(Mandatory)][string]$RsgOrRsc,
    [Parameter(Mandatory)][string]$ResourceName
  )
  try{
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
    param(
        $location = "eastus"
    )
            #Rsg--------------------------------------------------------------------------
            $ResourceGroupName = Create-ResourceName -ResourceType "Resource Group"
            while(Validate-ResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupName){
                Write-LogCustom -Message "The name $ResourceGroupName is not available in Azure"
                $ResourceGroupName = Create-ResourceName -ResourceType "Resource group"
            }
            Write-LogCustom -Message "New resource name $ResourceGroupName created successfully"
            #Create the resource
            New-AzResourceGroup -Name $ResourceGroupName -Location $location
            #Validate
            if(Validate-ResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupName){
                Write-LogCustom -Message "Resource Group $ResourceGroupName created successfully"
            }
            else{
                Write-LogCustom -Message "Failed to create Resource Group $ResourceGroupName"
            }
            #Nsg ----------------------------------------------------------------------
            #Create the name
            $NetworkSecurityGroupName = Create-ResourceName -ResourceType "Network Security Group"
            while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $NetworkSecurityGroupName){
                Write-LogCustom -Message "The name $NetworkSecurityGroupName is not available in Azure"
                $NetworkSecurityGroupName = Create-ResourceName -ResourceType "Network Security Group"
            }
            Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
            #Create the resource
            New-AzNetworkSecurityGroup `
                -ResourceGroupName $ResourceGroupName  `
                -Location $location `
                -Name $NetworkSecurityGroupName
            #validar que se haya creado
            if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $NetworkSecurityGroupName){
                Write-LogCustom -Message "Network Security Group $NetworkSecurityGroupName created successfully"
            }
            else{
                Write-LogCustom -Message "Failed to create Network Security Group $NetworkSecurityGroupName"
            }
            #Vnt y Sbn ------------------------------------------------------------
            #Create the name SBN
            $SubnetName = Create-ResourceName -ResourceType "Subnet"
            while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $SubnetName){
                Write-LogCustom -Message "The name $SubnetName is not available in Azure"
                $SubnetName = Create-ResourceName -ResourceType "Subnet"
            }
            Write-LogCustom -Message "New resource name $SubnetName created successfully"
            #Create the name VNT
            $VirtualNetworkName = Create-ResourceName -ResourceType "Virtual Network"
            while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $VirtualNetworkName){
                Write-LogCustom -Message "The name $VirtualNetworkName is not available in Azure"
                $VirtualNetworkName = Create-ResourceName -ResourceType "Virtual Network"
            }
            Write-LogCustom -Message "New resource name $VirtualNetworkName created successfully"
            #Create the resource
            $newSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix "10.0.1.0/24"
            New-AzVirtualNetwork `
            -Name $VirtualNetworkName `
            -ResourceGroupName $ResourceGroupName `
            -Location $location `
            -AddressPrefix "10.0.0.0/16" `
            -Subnet $newSubnet
            #Validate
            if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $VirtualNetworkName){
                Write-LogCustom -Message "Virtual Network $VirtualNetworkName created successfully"
            }
            else{
                Write-LogCustom -Message "Failed to create Virtual Network $VirtualNetworkName"
            }
            #Validate
            if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $VirtualNetworkName){
                Write-LogCustom -Message "Subnet $SubnetName created successfully"
            }
            else{
                Write-LogCustom -Message "Failed to create Subnet $SubnetName"
            }
            #Akv ------------------------------------------------------------
            #Create the name
            $KeyVaultName = Create-ResourceName -ResourceType "Key Vault"
            #Validate
            while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $KeyVaultName){
                Write-LogCustom -Message "The name $KeyVaultName is not available in Azure"
                $KeyVaultName = Create-ResourceName -ResourceType "Key Vault"
            }
            Write-LogCustom -Message "New resource name $KeyVaultName created successfully"
            #Create the resource
                New-AzKeyVault  `
                    -Name $KeyVaultName `
                    -ResourceGroupName $ResourceGroupName `
                    -Location $location `
            #Validate
            if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $KeyVaultName){
                Write-LogCustom -Message "Key Vault $KeyVaultName created successfully"
            }
            else{
                Write-LogCustom -Message "Failed to create Key Vault $KeyVaultName"
            }
            #Sta ------------------------------------------------------------
            #Create the name
            $StorageAccountName = Create-ResourceName -ResourceType "Storage Account"
            #Validate
            while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $StorageAccountName){
                Write-LogCustom -Message "The name $StorageAccountName is not available in Azure"
                $StorageAccountName = Create-ResourceName -ResourceType "Storage Account"
            }
            Write-LogCustom -Message "New resource name $StorageAccountName created successfully"
            #Create the resource
                New-AzStorageAccount `
                    -Name $StorageAccountName `
                    -SkuName "Standard_GRS" `
                    -Kind "Storage" `
                    -ResourceGroupName $ResourceGroupName `
                    -Location $location
            #Validate
            $existingSta = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
            if($existingSta){
                Write-LogCustom -Message "Storage Account $StorageAccountName created successfully"
            }
            else{
                Write-LogCustom -Message "Failed to create Storage Account $StorageAccountName"
            }
            #Azf ------------------------------------------------------------
            #Create the name
            $AzureFunctionAppName = Create-ResourceName -ResourceType "Azure Function App"
            #Validate
            while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $AzureFunctionAppName){
                Write-LogCustom -Message "The name $AzureFunctionAppName is not available in Azure"
                $AzureFunctionAppName = Create-ResourceName -ResourceType "Azure Function App"
            }
            Write-LogCustom -Message "New resource name $AzureFunctionAppName created successfully"
            #Create the resource
                New-AzFunctionApp  `
                    -Location $location  `
                    -Name $AzureFunctionAppName `
                    -ResourceGroupName $ResourceGroupName `
                    -Runtime PowerShell `
                    -StorageAccountName $StorageAccountName
            #Validate
            if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $AzureFunctionAppName){
                Write-LogCustom -Message "Azure Function App $AzureFunctionAppName created successfully"
            }
            else{
                Write-LogCustom -Message "Failed to create Azure Function App $AzureFunctionAppName"
            }
            #Asp ------------------------------------------------------------
            #Create the name
            $AppServicePlanName = Create-ResourceName -ResourceType "App Service Plan"
            #Validate
            while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $AppServicePlanName){
                Write-LogCustom -Message "The name $AppServicePlanName is not available in Azure"
                $AppServicePlanName = Create-ResourceName -ResourceType "App Service Plan"
            }
            Write-LogCustom -Message "New resource name $AppServicePlanName created successfully"
            #Create the resource
                New-AzAppServicePlan  `
                    -Name $AppServicePlanName `
                    -ResourceGroupName $ResourceGroupName `
                    -Location $location
            #Validate
            if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $AppServicePlanName){
                Write-LogCustom -Message "App Service Plan $AppServicePlanName created successfully"
            }
            else{
                Write-LogCustom -Message "Failed to create App Service Plan $AppServicePlanName"
            }
}

# Functions to deploy the resources using ARM Templates
function Create-ResourceGroup {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    $location = "eastus"
  )
  if (!(Validate-ResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupName)) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $location
  }
}
function Create-NetworkSecurityGroup {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$NetworkSecurityGroupName,
    $location = "eastus"
  )
  # 
  New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName -ResourceGroupName $ResourceGroupName -Location $location
  #validar que se haya creado
  if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $NetworkSecurityGroupName){
    Write-LogCustom -Message "Network Security Group $NetworkSecurityGroupName created successfully"
  }
  else{
    Write-LogCustom -Message "Failed to create Network Security Group $NetworkSecurityGroupName"
  }
}
function Create-VirtualNetwork{
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$VirtualNetworkName,
    $location = "eastus",
    $templateFile = ".\arm\virtualnetwork.json"
  )
    $hashtableParameters = @{
      virtualnetworkName = $VirtualNetworkName
      location = $location
    }            
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -TemplateParameterObject $hashtableParameters

    if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $VirtualNetworkName){
      Write-LogCustom -Message "Virtual Network $VirtualNetworkName created successfully"
    }
    else{
      Write-LogCustom -Message "Failed to create Virtual Network $VirtualNetworkName"
    }
}
function Create-Subnet{
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$VirtualNetworkName,
    [Parameter(Mandatory)][string]$SubnetName,
    $location = "eastus",
    $templateFile = ".\arm\subnet.json"
  )
  $hashtableParameters = @{
    virtualnetworkName = $VirtualNetworkName
    subnetName= $SubnetName
    location = $location
  }            
  New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -TemplateParameterObject $hashtableParameters    

    if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $VirtualNetworkName){
      Write-LogCustom -Message "Subnet $SubnetName created successfully"
    }
    else{
      Write-LogCustom -Message "Failed to create Subnet $SubnetName"
    }
}
function Create-StorageAccount{
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$StorageAccountName,
    $templateFile = ".\arm\storageaccount.json"
  )

  $hashtableParameters = @{
    storageAccountName = $StorageAccountName
  }        
  New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -TemplateParameterObject $hashtableParameters
  #validar que se haya creado
  # $existingSta = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
  # if($existingSta){
  #   Write-LogCustom -Message "Storage Account $StorageAccountName created successfully"
  # }
  # else{
  #   Write-LogCustom -Message "Failed to create Storage Account $StorageAccountName"
  # }
}
function Create-AppServicePlan {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$AppServicePlanName,
    $location = "eastus"
  )

  New-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -Location $location -Tier "Basic" -NumberofWorkers 2 -WorkerSize "Small"

  if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $AppServicePlanName){
    Write-LogCustom -Message "App Service Plan $AppServicePlanName created successfully"
  }
  else{
    Write-LogCustom -Message "Failed to create App Service Plan $AppServicePlanName"
  }
}
function Create-AzureFunctionApp{
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$StorageAccountName,
    [Parameter(Mandatory)][string]$AzureFunctionAppName,
    $location = "eastus"
  )

  New-AzFunctionApp -Name $AzureFunctionAppName -ResourceGroupName $ResourceGroupName -StorageAccount $StorageAccountName -Runtime PowerShell -FunctionsVersion 4 -Location $location

  if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $AzureFunctionAppName){
    Write-LogCustom -Message "Azure Function App $AzureFunctionAppName created successfully"
  }
  else{
    Write-LogCustom -Message "Failed to create Azure Function App $AzureFunctionAppName"
  }
}
function Create-KeyVault {
  param(
    [Parameter(Mandatory)][string]$ResourceGroupName,
    [Parameter(Mandatory)][string]$KeyVaultName,
    $email = "Constanza.Pugliese@gds.ey.com",
    $location = "eastus",
    $templateFile = ".\arm\keyvault.json"
  )
  $tenantID=(Get-AzTenant).id
  $objectID = (Get-AzADUser -UserPrincipalName $email).Id  
  $hashtableParameters = @{
    keyVaultName = $KeyVaultName
    location = $location
    sku= "Standard"
    tenantId= $tenantID
    objectId = $objectID
  }
  New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -TemplateParameterObject $hashtableParameters

  if(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $KeyVaultName){
    Write-LogCustom -Message "Key Vault Name $KeyVaultName created successfully"
  }
  else{
    Write-LogCustom -Message "Failed to create Key Vault Name $KeyVaultName"
  }
}

#Function to delete the resources
function Delete-Resource {
  # Everything will be inside the same resource group
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
    if ($ResourceGroupName) {
        $existingResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
        if ($null -eq $existingResourceGroup) {
            Write-LogCustom -Message "There is no Resource Group named $ResourceGroupName"
        }
        else {
            Write-LogCustom -Message "Starting deleted of Resource Group named $ResourceGroupName.."
            $r = Remove-AzResourceGroup -Name $ResourceGroupName -Force
            Start-sleep -Seconds 10
            $existingResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
            if (!$existingResourceGroup) {
                Write-LogCustom -Message "The Resource Group $ResourceGroupName was deleted successfully "
            }
        }
    }
    if ($NetworkSecurityGroupName) {
        $allresource = Get-AzResource | Where-Object { $_.Name -eq $NetworkSecurityGroupName } | Select-Object ResourceGroupName
        if ($null -eq $allresource) {
            Write-LogCustom -Message "There is no Network Security Group named $NetworkSecurityGroupName"
        }
        else {
            $listresource = @()
            foreach ($resource in $allresource) {
                $listresource += $resource.ResourceGroupName
            }
            if ($listresource.Count -ge 2) {
                Write-LogCustom -Message "There are more than one resource with the name $NerworkSecurityGroupName. Please, write the Resource Group Name to continue with the deleted."
                $RGN = Read-Host("Resourse Group Name")
                Remove-AzResource `
                    -ResourceGroupName $RGN `
                    -ResourceName $NetworkSecurityGroupName `
                    -ResourceType Microsoft.Network/networkSecurityGroups `
                    -Force
            }
            else {
                Write-LogCustom -Message "Starting deleted of Network Security Group named $NetworkSecurityGroupName.."
                $r = Remove-AzResource `
                    -ResourceGroupName $listresource[0] `
                    -ResourceName $NetworkSecurityGroupName `
                    -ResourceType Microsoft.Network/networkSecurityGroups `
                    -Force
                Start-sleep -Seconds 10
                #$existingResource = Get-AzResource | Where-Object { $_.Name -eq $NetworkSecurityGroupName }
                if ($r -eq $true) {
                    Write-LogCustom -Message "The Network Security Group $NetworkSecurityGroupName deleted successfully"
                }
                else {
                    Write-LogCustom -Message "Failed to delete Network Security Group named $NetworkSecurityGroupName"
                }
            }
        }
    }
    if ($VirtualNetworkName) {
        $allresource = Get-AzResource | Where-Object { $_.Name -eq $VirtualNetworkName } | Select-Object ResourceGroupName
        if ($null -eq $allresource) {
            Write-LogCustom -Message "There is no Virtual Network named $VirtualNetworkName"
        }
        else {
            $listresource = @()
            foreach ($resource in $allresource) {
                $listresource += $resource.ResourceGroupName
            }
            if ($listresource.Count -ge 2) {
                Write-LogCustom -Message "There are more than one resource with the name $VirtualNetworkName. Please, write the ResourceGroupName to continue with the deleted."
                $RGN = Read-Host("Resourse Group Name")
                Remove-AzResource `
                    -ResourceGroupName $RGN `
                    -ResourceName $VirtualNetworkName `
                    -ResourceType Microsoft.Network/virtualNetworks `
                    -Force
            }
            else {
                Write-LogCustom -Message "Starting deleted of Virtual Network named $VirtualNetworkName.."
                $r = Remove-AzResource `
                    -ResourceGroupName $listresource[0] `
                    -ResourceName $VirtualNetworkName `
                    -ResourceType Microsoft.Network/virtualNetworks `
                    -Force
                Start-sleep -Seconds 10
                # $existingResource = Get-AzResource | Where-Object { $_.Name -eq $VirtualNetworkName }
                if ($r -eq $true) {
                    Write-LogCustom -Message "The Virtual Network $VirtualNetworkName was deleted successfully"
                }
                else {
                    Write-LogCustom -Message "Failed to delete Virtual Network named $VirtualNetworkName"
                }
            }
        }
    }
    if ($SubnetName) {
      Write-LogCustom -Message "To delete a Subnet you have to delete the Virtual Network"
    }
    if ($KeyVaultName) {
        $allresource = Get-AzResource | Where-Object { $_.Name -eq $KeyVaultName } | Select-Object ResourceGroupName
        if ($null -eq $allresource) {
            Write-LogCustom -Message "There is no Key Vault named $KeyVaultName"
        }
        else {
            $listresource = @()
            foreach ($resource in $allresource) {
                $listresource += $resource.ResourceGroupName
            }
            if ($listresource.Count -ge 2) {
                Write-LogCustom -Message "There are more than one resource with the name $KeyVaultName. Please, write the ResourceGroupName to continue with the deleted."
                $RGN = Read-Host("Resourse Group Name")
                Remove-AzResource `
                    -ResourceGroupName $RGN `
                    -ResourceName $KeyVaultName `
                    -ResourceType Microsoft.KeyVault/vaults `
                    -Force
            }
            else {
                Write-LogCustom -Message "Starting deleted of Key Vault named $KeyVaultName.."
                $r = Remove-AzResource `
                    -ResourceGroupName $listresource[0] `
                    -ResourceName $KeyVaultName `
                    -ResourceType Microsoft.KeyVault/vaults `
                    -Force
                Start-sleep -Seconds 10
                # $existingResource = Get-AzResource | Where-Object { $_.Name -eq $KeyVaultName }
                if ($r -eq $true) {
                    Write-LogCustom -Message "The Key Vault $KeyVaultName was deleted successfully"
                }
                else {
                    Write-LogCustom -Message "Failed to delete Key Vault named $KeyVaultName"
                }
            }
        }
    }
    if ($StorageAccountName) {
        $allresource = Get-AzResource | Where-Object { $_.Name -eq $StorageAccountName } | Select-Object ResourceGroupName
        if ($null -eq $allresource) {
            Write-LogCustom -Message "There is no Storage Account named $StorageAccountName"
        }
        else {
            $listresource = @()
            foreach ($resource in $allresource) {
                $listresource += $resource.ResourceGroupName
            }
            if ($listresource.Count -ge 2) {
                Write-LogCustom -Message "There are more than one resource with the name $StorageAccountName. Please, write the ResourceGroupName to continue with the deleted."
                $RGN = Read-Host("Resourse Group Name")
                Remove-AzResource `
                    -ResourceGroupName $RGN `
                    -ResourceName $StorageAccountName `
                    -ResourceType Microsoft.Storage/storageAccounts `
                    -Force
            }
            else {
                Write-LogCustom -Message "Starting deleted of Storage Account named $StorageAccountName.."
                $r = Remove-AzResource `
                    -ResourceGroupName $listresource[0] `
                    -ResourceName $StorageAccountName `
                    -ResourceType Microsoft.Storage/storageAccounts `
                    -Force
                Start-sleep -Seconds 10
                # $existingResource = Get-AzResource | Where-Object { $_.Name -eq $StorageAccountName }
                if ($r -eq $true) {
                    Write-LogCustom -Message "The Storage Account $StorageAccountName was deleted successfully"
                }
                else {
                    Write-LogCustom -Message "Failed to delete Storage Account named $StorageAccountName"
                }
            }
        }
    }
    if ($AppServicePlanName) {
        $allresource = Get-AzResource | Where-Object { $_.Name -eq $AppServicePlanName } | Select-Object ResourceGroupName
        if ($null -eq $allresource) {
            Write-LogCustom -Message "There is no App Service Plan named $AppServicePlanName"
        }
        else {
            $listresource = @()
            foreach ($resource in $allresource) {
                $listresource += $resource.ResourceGroupName
            }
            if ($listresource.Count -ge 2) {
                Write-LogCustom -Message "There are more than one resource with the name $AppServicePlanName. Please, write the ResourceGroupName to continue with the deleted."
                $RGN = Read-Host("Resourse Group Name")
                Remove-AzResource `
                    -ResourceGroupName $RGN `
                    -ResourceName $AppServicePlanName `
                    -ResourceType Microsoft.Web/serverfarms `
                    -Force
            }
            else {
                Write-LogCustom -Message "Starting deleted of App Service Plan named $AppServicePlanName.."
                $r = Remove-AzResource `
                    -ResourceGroupName $listresource[0] `
                    -ResourceName $AppServicePlanName `
                    -ResourceType Microsoft.Web/serverfarms `
                    -Force
                Start-sleep -Seconds 10
                # $existingResource = Get-AzResource | Where-Object { $_.Name -eq $AppServicePlanName }
                if ($r -eq $true) {
                    Write-LogCustom -Message "The App Service Plan $AppServicePlanName was deleted successfully"
                }
                else {
                    Write-LogCustom -Message "Failed to delete App Service Plan named $AppServicePlanName"
                }
            }
        }
    }
    if ($AzureFunctionAppName) {
        $allresource = Get-AzResource | Where-Object { $_.Name -eq $AzureFunctionAppName } | Select-Object ResourceGroupName
        if ($null -eq $allresource) {
            Write-LogCustom -Message "There is no Azure Function App named $AzureFunctionAppName"
        }
        else {
            $listresource = @()
            foreach ($resource in $allresource) {
                $listresource += $resource.ResourceGroupName
            }
            # devuelve por defecto 2 recursos, entonces validamos con 3
            if ($listresource.Count -ge 3) {
                Write-LogCustom -Message "There are more than one resource with the name $AzureFunctionAppName. Please, write the ResourceGroupName to continue with the deleted."
                $RGN = Read-Host("Resourse Group Name")
                Remove-AzResource `
                    -ResourceGroupName $RGN `
                    -ResourceName $AzureFunctionAppName `
                    -ResourceType Microsoft.Web/sites `
                    -Force
            }
            else {
                Write-LogCustom -Message "Starting deleted of Azure Function App named $AzureFunctionAppName.."
                $r = Remove-AzResource `
                    -ResourceGroupName $listresource[0] `
                    -ResourceName $AzureFunctionAppName `
                    -ResourceType Microsoft.Web/sites `
                    -Force
                Start-sleep -Seconds 10
                # $existingResource = Get-AzResource | Where-Object { $_.Name -eq $AzureFunctionAppName }
                if ($r -eq $true) {
                    Write-LogCustom -Message "The Azure Function App $AzureFunctionAppName was deleted successfully"
                }
                else {
                    Write-LogCustom -Message "Failed to delete Azure Function App named $AzureFunctionAppName"
                }
            }
        }
    }
}

# Script Start
Connect-AzAccount | Out-Null
if($Action -eq "create"){
  # Create everything (switch parameters false)
  if(!$ResourceGroup -and !$NetworkSecurityGroup -and !$VirtualNetwork -and !$Subnet -and !$KeyVault -and !$StorageAccount -and !$AppServicePlan -and !$AzureFunctionApp){
    Create-AllResources
  }
  else{
    # Crear por recurso
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
    # si no selecciono solo rsg, creo el/los recursos dentro del mismo rsg
    if($NetworkSecurityGroup){
      # Valido que recibí un nombre por parámetro, que respete la EY naming convention o voy a genear alguno y lo voy a guardar
      if($NetworkSecurityGroupName){
        if(Validate-ResourceName -ResourceName $NetworkSecurityGroupName) {
          Write-LogCustom -Message "The name $NetworkSecurityGroupName respects the EY naming convention"
        }
        else{
          Write-LogCustom -Message "The name $NetworkSecurityGroupName is not valid according to EY naming convention"
          Write-LogCustom -Message "The name $NetworkSecurityGroupName is not valid according to EY naming convention"
          $NetworkSecurityGroupName = Create-ResourceName -ResourceType "Network Security Group"
          Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
        }
      }
      else{
        Write-LogCustom -Message "The user did not define a name"
        $NetworkSecurityGroupName = Create-ResourceName -ResourceType "Network Security Group"
        Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
      }
      # Valido que el nombre elegido o creado, esté disponible en Azure o lo voy a recrear hasta que no exista uno igual
      while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $NetworkSecurityGroupName){
        Write-LogCustom -Message "The name $NetworkSecurityGroupName is not available in Azure"
        $NetworkSecurityGroupName = Create-ResourceName -ResourceType "Network Security Group"
      }
      # do while?
      # Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
      Create-NetworkSecurityGroup -ResourceGroupName $ResourceGroupName -NetworkSecurityGroupName $NetworkSecurityGroupName
    }
    if ($VirtualNetwork){
      if($VirtualNetworkName){
        if(Validate-ResourceName -ResourceName $VirtualNetworkName) {
          Write-LogCustom -Message "The name $VirtualNetworkName respects the EY naming convention"
        }
        else{
          Write-LogCustom -Message "The name $VirtualNetworkName is not valid according to EY naming convention"
          $VirtualNetworkName = Create-ResourceName -ResourceType "Virtual Network"
          Write-LogCustom -Message "New resource name $VirtualNetworkName created successfully"
        }
      }
      else{
        Write-LogCustom -Message "The user did not define a name"
        $VirtualNetworkName = Create-ResourceName -ResourceType "Virtual Network"
        Write-LogCustom -Message "New resource name $VirtualNetworkName created successfully"
      }
      # Valido que el nombre elegido o creado, esté disponible en Azure o lo voy a recrear hasta que no exista uno igual
      while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $VirtualNetworkName){
        Write-LogCustom -Message "The name $VirtualNetworkName is not available in Azure"
        $VirtualNetworkName = Create-ResourceName -ResourceType "Virtual Network"
      }
      # do while?
      # Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
      $global:VirtualNetworkNameGlobal = $VirtualNetworkName
      Create-VirtualNetwork -ResourceGroupName $ResourceGroupName -VirtualNetworkName $VirtualNetworkName
    }
    if($Subnet){
      if($VirtualNetworkNameGlobal){
        if($SubnetName){
          if(Validate-ResourceName -ResourceName $SubnetName) {
            Write-LogCustom -Message "The name $SubnetName respects the EY naming convention"
          }
          else{
            Write-LogCustom -Message "The name $SubnetName is not valid according to EY naming convention"
            $SubnetName = Create-ResourceName -ResourceType "Subnet"
            Write-LogCustom -Message "New resource name $SubnetName created successfully"
          }
        }
        else{
          Write-LogCustom -Message "The user did not define a name"
          $SubnetName = Create-ResourceName -ResourceType "Subnet"
          Write-LogCustom -Message "New resource name $SubnetName created successfully"
        }
        # Valido que el nombre elegido o creado, esté disponible en Azure o lo voy a recrear hasta que no exista uno igual
        # while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $VirtualNetworkNameGlobal){
        #   Write-LogCustom -Message "The name $SubnetName is not available in Azure"
        #   $SubnetName = Create-ResourceName -ResourceType "Subnet"
        # }
        # do while?
        # Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
        Create-Subnet -ResourceGroupName $ResourceGroupName -VirtualNetworkName $VirtualNetworkNameGlobal -SubnetName $SubnetName
      }
      else{
        Write-LogCustom -Message "Subnet needs a Virtual Network to be deployed"
      }
    }
    if($StorageAccount){
      if($StorageAccountName){
        if(Validate-ResourceName -ResourceName $StorageAccountName) {
          Write-LogCustom -Message "The name $StorageAccountName respects the EY naming convention"
        }
        else{
          Write-LogCustom -Message "The name $StorageAccountName is not valid according to EY naming convention"
          $StorageAccountName = Create-ResourceName -ResourceType "Storage Account"
          Write-LogCustom -Message "New resource name $StorageAccountName created successfully"
        }
      }
      else{
        Write-LogCustom -Message "The user did not define a name"
        $StorageAccountName = Create-ResourceName -ResourceType "Storage Account"
        Write-LogCustom -Message "New resource name $StorageAccountName created successfully"
      }
      # Valido que el nombre elegido o creado, esté disponible en Azure o lo voy a recrear hasta que no exista uno igual
      # $existingSta = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
      # while($existingSta){
      #   Write-LogCustom -Message "The name $StorageAccountName is not available in Azure"
      #   $StorageAccountName = Create-ResourceName -ResourceType "Storage Account"
      # }
      # do while?
      # Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
      $global:StorageAccountNameGlobal = $StorageAccountName
      Create-StorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName
    }
    if($AppServicePlan){
      if($StorageAccountNameGlobal){
        if($AppServicePlanName){
          if(Validate-ResourceName -ResourceName $AppServicePlanName) {
            Write-LogCustom -Message "The name $AppServicePlanName respects the EY naming convention"
          }
          else{
            Write-LogCustom -Message "The name $AppServicePlanName is not valid according to EY naming convention"
            $AppServicePlanName = Create-ResourceName -ResourceType "App Service Plan"
            Write-LogCustom -Message "New resource name $AppServicePlanName created successfully"
          }
        }
        else{
          Write-LogCustom -Message "The user did not define a name"
          $AppServicePlanName = Create-ResourceName -ResourceType "App Service Plan"
          Write-LogCustom -Message "New resource name $AppServicePlanName created successfully"
        }
        # Valido que el nombre elegido o creado, esté disponible en Azure o lo voy a recrear hasta que no exista uno igual
        while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $AppServicePlanName){
          Write-LogCustom -Message "The name $AppServicePlanName is not available in Azure"
          $AppServicePlanName = Create-ResourceName -ResourceType "App Service Plan"
        }
        # do while?
        # Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
        Create-AppServicePlan -ResourceGroupName $ResourceGroupName -AppServicePlanName $AppServicePlanName
      }
      else{
        Write-LogCustom -Message "App Service Plan needs a Storage Account to be deployed"
      }
    }
    if($AzureFunctionApp){
      if($StorageAccountNameGlobal){
        if($AzureFunctionAppName){
          if(Validate-ResourceName -ResourceName $AzureFunctionAppName) {
            Write-LogCustom -Message "The name $AzureFunctionAppName respects the EY naming convention"
          }
          else{
            Write-LogCustom -Message "The name $AzureFunctionAppName is not valid according to EY naming convention"
            $AzureFunctionAppName = Create-ResourceName -ResourceType "App Service Plan"
            Write-LogCustom -Message "New resource name $AzureFunctionAppName created successfully"
          }
        }
        else{
          Write-LogCustom -Message "The user did not define a name"
          $AzureFunctionAppName = Create-ResourceName -ResourceType "Azure Function App"
          Write-LogCustom -Message "New resource name $AzureFunctionAppName created successfully"
        }
        # Valido que el nombre elegido o creado, esté disponible en Azure o lo voy a recrear hasta que no exista uno igual
        while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $AzureFunctionAppName){
          Write-LogCustom -Message "The name $AzureFunctionAppName is not available in Azure"
          $AzureFunctionAppName = Create-ResourceName -ResourceType "Azure Function App"
        }
        # do while?
        # Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
        Create-AzureFunctionApp -ResourceGroupName $ResourceGroupName -StorageAccount $StorageAccountNameGlobal -AzureFunctionAppName $AzureFunctionAppName
      }
      else{
        Write-LogCustom -Message "Azure Function App needs a Storage Account to be deployed"
      }
    }
    if($KeyVault){
      if($KeyVaultName){
        if(Validate-ResourceName -ResourceName $KeyVaultName) {
          Write-LogCustom -Message "The name $KeyVaultName respects the EY naming convention"
        }
        else{
          Write-LogCustom -Message "The name $KeyVaultName is not valid according to EY naming convention"
          $KeyVaultName = Create-ResourceName -ResourceType "Key Vault"
          Write-LogCustom -Message "New resource name $KeyVaultName created successfully"
        }
      }
      else{
        Write-LogCustom -Message "The user did not define a name"
        $KeyVaultName = Create-ResourceName -ResourceType "Key Vault"
        Write-LogCustom -Message "New resource name $KeyVaultName created successfully"
      }
      # Valido que el nombre elegido o creado, esté disponible en Azure o lo voy a recrear hasta que no exista uno igual
      while(Validate-ResourceExists -RsgOrRsc "rsc" -ResourceName $KeyVaultName){
        Write-LogCustom -Message "The name $KeyVaultName is not available in Azure"
        $KeyVaultName = Create-ResourceName -ResourceType "Key Vault"
      }
      # do while?
      # Write-LogCustom -Message "New resource name $NetworkSecurityGroupName created successfully"
      Create-KeyVault -ResourceGroupName $ResourceGroupName -KeyVaultName $KeyVaultName
    }
  }
}
elseif($Action -eq "delete"){
  #Cuando se usa solo el parametro delete, se elimina el ultimo resource group creado previamente con este script con el parametro -create.
  #En el caso de que no exista un recurso, el 'else' te avisa que no hay un recurso creado previamente y te sugiere otras acciones.
  if ($ResourceGroupNameGlobal -and !$All -and !$ResourceGroupName -and !$NetworkSecurityGroupName -and !$VirtualNetworkName -and !$SubnetName -and !$KeyVaultName -and !$StorageAccountName -and !$AppServicePlanName -and !$AzureFunctionAppName) {
    if (Validate-ResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupNameGlobal) {
      Write-LogCustom -Message "Starting deleted of Resource Group named $ResourceGroupNameGlobal.."
      $r = Remove-AzResourceGroup -Name $ResourceGroupNameGlobal -Force
      Start-sleep -Seconds 10
    #valida que se haya borrado
    if (!(Validate-ResourceExists -RsgOrRsc "rsg" -ResourceName $ResourceGroupNameGlobal)) {
      Write-LogCustom -Message "The Resource Group $ResourceGroupNameGlobal deleted successfully"
    }
    else{
      Write-LogCustom -Message "Failed to delete Resource Group $ResourceGroupNameGlobal"
    }
  }
  }
  #Usando el parametro -All se eliminan todos los Resource Groups dentro de la suscripcion.
  elseif ($All) {
      $AllResourceGroups = Get-AzResourceGroup | Select-Object ResourceGroupName
      if ($null -eq $AllResourceGroups) {
        Write-LogCustom -Message "There are not Resource Groups to delete."
      }
      else {
          $ListResourceGroups = @()
          foreach ($resource in $AllResourceGroups) {
              $ListResourceGroups += $resource.ResourceGroupName
          }
          Write-LogCustom -Message "Starting delete of all the Resource Groups"
          foreach ($resource in $ListResourceGroups) {
              $r = Remove-AzResourceGroup -Name $resource -Force
              $existingResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $resource }
              if (!$existingResourceGroup) {
                  Write-LogCustom -Message  "Resource Group $resource deleted successfully"
              }
              else {
                  Write-LogCustom -Message "Failed to delete the Resource Group $resource"
              }
          }
      }
  }
  #En el caso de que se agreguen los demás parametros, se puede optar por elegir eliminar recursos individuales nombrandolos por su nombre.
  #No es necesario que esten en el mismo Resource Group ni especificar a que Resource Group pertenece.
  #Solo en el caso de que haya dos recursos con el mismo nombre, te lo avisa desde el log y pide que ingreses el Resource Group
  elseif ($ResourceGroupName -or $NetworkSecurityGroupName -or $VirtualNetworkName -or $SubnetName -or $KeyVaultName -or $StorageAccountName -or $AppServicePlanName -or $AzureFunctionAppName) {
      Delete-Resource -ResourceGroupName $ResourceGroupName -NetworkSecurityGroupName $NetworkSecurityGroupName -VirtualNetworkName $VirtualNetworkName -SubnetName $SubnetName -KeyVaultName $KeyVaultName -StorageAccountName $StorageAccountName -AppServicePlanName $AppServicePlanName -AzureFunctionAppName $AzureFunctionAppName
  }
  else {
    Write-LogCustom -Message "You haven't created a resource using this script yet. If you want to delete an existing Resource Group type parameter -ResourceGroupName, or if you want to delete ALL Resources Groups type parameter -All"
  }
}
  