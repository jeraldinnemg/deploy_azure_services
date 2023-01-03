param(
    [Parameter(Mandatory)]$action,
    $location = "eastus",
    [string]$rgName,
    [string]$nsgName,
    [string]$vnetName,
    [string]$subnetName,
    [string]$kvName,
    [string]$saName,
    [string]$aspName,
    [string]$afaName
)

Connect-AzAccount

Function ValidateName($string) {
    $validationRegex = '^[A-Za-z]{2}[A-Za-z]{3}[A-Za-z]{1}[0-9]{6}[A-Za-z]{3}[0-9]{2}$'
    try{
        if ($string -match $validationRegex) {
            return 1
        }
    }
    catch{
        Write-LogCustom -Message "The name of the resource is not valid according to EY naming convention"
      }
}

if ($action -eq 'create') {
    Write-Output "####################"
    Write-Output "Creation of resources"
    Write-Output "####################"
    
    if ($rgName) {
        Write-Output "Creation of resource group..."
        if (ValidateName($rgName) -eq 1) {
            $existingRG = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $rgName }
            if (!$existingRG) {
                Write-Output "####################"
                Write-Output "Creating Resource Group"
                Write-Output "####################"           
                try {
                    New-AzResourceGroup -Name $rgName -Location $location
                }
                catch {
                    Throw "Deployment of RG failed: $_"
                }                
            }
            else { Write-Output "The name is not available" }      
        }
        else { 
            # If resource name is not valid, display error message
            Write-Output("Please the name of the resource is not valid according to EY naming convention:
            Cloud provider 2 chars,
            Location 3 chars,
            Environment 1 char,
            DeploymentID 6 chars,
            Resource Type 3 chars y
            Sequence 2 chars. Example: azeusd123456asp01") 
        }
    }

    if ($nsgName) {
        Write-Output "Creation of Network Security Group"
        if (ValidateName($nsgName) -eq 1) {
            Write-Output "The name is valid"
            $existingNSG = Get-AzNetworkSecurityGroup | Where-Object { ($_.Name -eq $nsgName) -and ($_.ResourceGroupName -eq $RGName ) }
            if (!$existingNSG) {
                Write-Output "#################################"
                Write-Output "Creating Network Security Group"
                Write-Output "#################################"           
                try {
                    New-AzNetworkSecurityGroup 
                    -Name $nsgName 
                    -ResourceGroupName $rgName 
                    -Location $location
                }
                catch {
                    Throw "Deployment of NSG failed: $_"
                }                
            }
            else { Write-Output "NSG name not available" }      
        }

        else { 
            # If resource name is not valid, display error message
            Write-Output("Please the name of the resource is not valid according to EY naming convention:
            Cloud provider 2 chars,
            Location 3 chars,
            Environment 1 char,
            DeploymentID 6 chars,
            Resource Type 3 chars y
            Sequence 2 chars. Example: azeusd123456asp01") 
        }
    }

    if ($aspName) {
        Write-Output "Creation of App Service Plan"
        if (ValidateName($aspName) -eq 1) {
            $existingASP = Get-AzAppServicePlan | Where-Object { ($_.Name -eq $aspName) -and ($_.ResourceGroupName -eq $RGName ) }
            if (!$existingASP) {
                Write-Output "#############################"
                Write-Output "Creation of App Service Plan"
                Write-Output "#############################"           
                try {
                    New-AzAppServicePlan 
                    -Name $aspName 
                    -ResourceGroupName $rgName 
                    -Location $location
                    -TemplateFile "appservicePlan.json"
                    -TemplateParameterFile "appserviceplanparameters.parameters.json"
                }
                catch {
                    Throw "Deployment of ASP failed: $_"
                }                
            }
            else { Write-Output "ASP name not available" }      
        }
        else { 
            # If resource name is not valid, display error message
            Write-Output("Please the name of the resource is not valid according to EY naming convention:
            Cloud provider 2 chars,
            Location 3 chars,
            Environment 1 char,
            DeploymentID 6 chars,
            Resource Type 3 chars y
            Sequence 2 chars. Example: azeusd123456asp01") 
        }
    }

    
    if ($SAName) {
        Write-Output "Creation of Storage Account"
        if (ValidateName($saName) -eq 1) {
            $existingSA = Get-AzStorageAccount -ResourceGroupName $rgName -Name $saName
            if (!$existingSA) {
                Write-Output "####################"
                Write-Output "Creation of Storage Account"
                Write-Output "####################"           
                try {
                    $hashtableParameters = @{
                        storageAccountName = $saName
                    }        
                            
                    New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile "arm_templates\storageaccount.json" -TemplateParameterObject $hashtableParameters
                }
                catch {
                    Throw "Deployment of SA failed: $_"
                }                
            }
            else { Write-Output "SA name not available" }      
        }
                else { 
            # If resource name is not valid, display error message
            Write-Output("Please the name of the resource is not valid according to EY naming convention:
            Cloud provider 2 chars,
            Location 3 chars,
            Environment 1 char,
            DeploymentID 6 chars,
            Resource Type 3 chars y
            Sequence 2 chars. Example: azeusd123456asp01") 
        }
    }

    if ($AFAName) {
        Write-Output "Creation of Azure Function App"
        if (ValidateName($afaName) -eq 1) {
            $existingAFA = 
            Get-AzFunctionApp | Where-Object { ($_.Name -eq $afaName) -and ($_.ResourceGroupName -eq $rgName ) }
            if (!$existingAFA) {
                Write-Output "####################"
                Write-Output "Creation of Azure Function App because the name does not exist"
                Write-Output "####################"           
                try {
                    New-AzFunctionApp -Name $AFAName -ResourceGroupName $RGName -Location $location -StorageAccountName $SAName -Runtime PowerShell
                }
                catch {
                    Throw "Deployment of AFA failed: $_"
                }                
            }
            else { Write-Output "AFA name not available" }      
        }
        else { 
            # If resource name is not valid, display error message
            Write-Output("Please the name of the resource is not valid according to EY naming convention:
            Cloud provider 2 chars,
            Location 3 chars,
            Environment 1 char,
            DeploymentID 6 chars,
            Resource Type 3 chars y
            Sequence 2 chars. Example: azeusd123456asp01") 
        }
    }

}

elseif ($action -eq 'delete') {
    Write-Output "Deletion of resources..."
    if ($NSGName) {
        $existingNSG = Get-AzNetworkSecurityGroup | Where-Object { ($_.Name -eq $nsgName) -and ($_.ResourceGroupName -eq $rgName ) }
        if ($existingNSG) {
            Remove-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName
        }
        else {
            Write-Output "The NSG does not exist"
        }
    }

    if ($aspName) {
        $existingASP = Get-AzAppServicePlan -ResourceGroupName $rgName -Name $aspName 
        if ($existingASP) {
            Remove-AzAppServicePlan -Name $aspName -ResourceGroupName $rgName 
        }
        else {
            Write-Output "The ASP does not exist"
        }
    }

    if ($afaName) {
        $existingAFA = 
        Get-AzFunctionApp| Where-Object { ($_.Name -eq $afaName) -and ($_.ResourceGroupName -eq $RGName ) }
        if ($existingAFA) {
            Remove-AzFunctionApp -Name $afaName -ResourceGroupName $rgName 
        }
        else {
            Write-Output "The AFA does not exist"
        }
    }
    if ($saName) {
        $existingSA = Get-AzStorageAccount -ResourceGroupName $rgName -Name $saName
        if ($existingSA) {
            Remove-AzStorageAccount -Name $saName -ResourceGroupName $rgName 
        }
        else {
            Write-Output "The SA does not exist"
        }
    }

    if ($rgName) {
        $existingRG = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $rgName }
        if ($existingRG) {
            Remove-AzResourceGroup -Name $rgName
        }
        else {
            Write-Output "The Resource Group does not exist"
        }
    }
    
}
