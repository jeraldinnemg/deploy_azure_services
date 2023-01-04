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
    if ($rgName) {

        if (ValidateName($rgName) -eq 1) {
            $existingRG = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $rgName }
            if (!$existingRG) {         
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
}
    if ($nsgName) {
        if (ValidateName($nsgName) -eq 1) {

            $existingNSG = Get-AzNetworkSecurityGroup | Where-Object { ($_.Name -eq $nsgName) -and ($_.ResourceGroupName -eq $RGName ) }
            if (!$existingNSG) {
        
                try {
                    New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rgName -Location $location
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
        if (ValidateName($aspName) -eq 1) {
            $existingASP = Get-AzAppServicePlan | Where-Object { ($_.Name -eq $aspName) -and ($_.ResourceGroupName -eq $rgName ) }
            if (!$existingASP) {   
                try {
                    
                    New-AzAppServicePlan -ResourceGroupName $rgName -Name $aspName -Location $location -Tier "Basic" -NumberofWorkers 2 -WorkerSize "Small"

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

    if ($kvName) {

        if (ValidateName($kvName) -eq 1) {
            $existingKV = Get-AzKeyVault -ResourceGroupName $rgName -Name $kvName
            if (!$existingKV) {    
                $tenantId=(Get-AzTenant).id     
                try {
                    $hashtableParameters = @{
                        keyVaultName = $kvName
                        location = $location
                        sku= "Standard"
                        tenantId= $tenantId
                    }        
                            
                    #New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile "arm_templates\keyvault.json" -TemplateParameterObject $hashtableParameters
                    New-AzKeyVault -ResourceGroupName $rgName -Name $kvName -Location $location 
                }
                catch {
                    Throw "Deployment of KV failed: $_"
                }                
            }
            else { Write-Output "KV name not available" }      
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


    if ($afaName) {
        Write-Output "Creation of Azure Function App"
        if (ValidateName($afaName) -eq 1) {
            $existingAFA = 
            Get-AzFunctionApp | Where-Object { ($_.Name -eq $afaName) -and ($_.ResourceGroupName -eq $rgName ) }
            if (!$existingAFA) {        
                try {
                # Variable block
                $functionApp = "msdocs-serverless-python-function-$randomIdentifier"
                $skuStorage = "Standard_LRS"
                $functionsVersion = "4"
                $pythonVersion = "3.9" #Allowed values: 3.7, 3.8, and 3.9  

                    #New-AzFunctionApp -Name $afaName -ResourceGroupName $rgName -Location $location -StorageAccountName $saName -Runtime PowerShell
                    New-AzFunctionApp -Name $afaName -StorageAccountName $saName -Location $location -ResourceGroupName $rgName -OSType Linux -Runtime Python -RuntimeVersion $pythonVersion -FunctionsVersion $functionsVersion
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

    if ($vnetName) {
        Write-Output "Creation of Storage Account"
        if (ValidateName($vnetName) -eq 1) {
            $existingVNET = Get-AzVirtualNetwork | Where-Object { $_.VirtualNetworkName -eq $vnetName }
            if (!$existingVNET) {         
                try {
                    $hashtableParameters = @{
                        virtualnetworkName = $vnetName
                        location = $location
                    }        
                            
                    New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile "arm_templates\virtualnetwork.json" -TemplateParameterObject $hashtableParameters
                }
                catch {
                    Throw "Deployment of VNET failed: $_"
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