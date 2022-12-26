param(

    [Parameter(Mandatory)]$rgName,
    [Parameter(Mandatory)]$location
)


# Log in to Azure
Connect-AzAccount

Write-Output "####################"
Write-Output "Getting Resource Details"
Write-Output "####################"



$existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName}


if(!$existingRG){
Write-Output "####################"
Write-Output "Creating Resource Group"
Write-Output "####################"

try {
    New-AzResourceGroup -Name $rgName -Location $location
}
catch {
    Throw "Deployment failed: $_"
}

}

else{

$hashtableParameters = @{
    storageAccountName = $storageAccountName
}

New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -TemplateFile "./storageDeploy.json" -TemplateParameterObject $hashtableParameters
}

# Prompt user to select resources to deploy or delete
Write-Host "Select the resources you want to deploy or delete:"
Write-Host "1. Resource Group"
Write-Host "2. Network Security Group"
Write-Host "3. Virtual Network"
Write-Host "4. Subnet"
Write-Host "5. Key Vault"
Write-Host "6. Storage Account"
Write-Host "7. App Service Plan"
Write-Host "8. Azure Function App"

# While user has not selected option "0" to finish, continue asking for actions on resources
while ($true) {
  # Read user's selected option and store it in a variable
  $selection = Read-Host "Enter the number of the selected option (or enter '0' to finish):"
  $resource = $null

  if ($selection -eq 1) {
    $resource = "Resource Group"
  } elseif ($selection -eq 2) {
    $resource = "Network Security Group"
  } elseif ($selection -eq 3) {
    $resource = "Virtual Network"
  } elseif ($selection -eq 4) {
    $resource = "Subnet"
  } elseif ($selection -eq 5) {
    $resource = "Key Vault"
  } elseif ($selection -eq 6) {
    $resource = "Storage Account"
  } elseif ($selection -eq 7) {
    $resource = "App Service Plan"
  } elseif ($selection -eq 8) {
    $resource = "Azure Function App"
  }

  # If user selected option "0", exit loop
  if ($selection -eq 0) {
    break
  }

  # Prompt user for resource name
  $resourceName = Read-Host "Enter the name of the resource:"

  # Validate resource name using regular expression
  $validationRegex = '^[A-Za-z]{2}\-[A-Za-z]{3}\-[A-Za-z]{1}\-[0-9]{6}\-[A-Za-z]{3}\-[0-9]{2}$'
  if ($resourceName -match $validationRegex) {
    # If resource name is valid, proceed with deployment or deletion
    # Prompt user to choose between creating or deleting the selected resource
    $action = Read-Host "Do you want to create or delete the selected resource? (enter 'create' or 'delete')"

    # If user selected "create", deploy resource using an ARM template
    if ($action -eq "create") {
      $resourceGroupName = Read-Host "Enter the name of the resource group where you want to create the resource:"
      $templateFilePath = Read-Host "Enter the path of the ARM template file you want to use for the deployment:"
      $templateParameterFilePath = Read-Host "Enter the path of the ARM template parameter file you want to use for the deployment:"
      New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $templateParameterFilePath
    }

    # If user selected "delete", delete the resource
    if ($action -eq "delete") {
      $resourceGroupName = Read-Host "Enter the name of the resource group where the resource is located:"
      Remove-AzResourceGroup -Name $resourceGroupName
    }
  } else {
    # If resource name is not valid, display error message
    Write-Output("Please the name of the resource is not valid according to EY naming convention:
    Cloud provider 2 chars,
    Location 3 chars,
    Environment 1 char,
    DeploymentID 6 chars,
    Resource Type 3 chars y
    Sequence 2 chars. Example: az-eus-d-123456-asp-01")
  }
}