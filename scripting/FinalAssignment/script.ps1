#Defining the parameters to deploy the resource
param(

    [Parameter(Mandatory)]$rgName,
    [Parameter(Mandatory)]$location,
    [Parameter(Mandatory)]$storageAccountName

)

# Define the resource types that can be deployed or deleted
$resourceTypes = @(
    "ResourceGroup",
    "NetworkSecurityGroup",
    "VirtualNetwork",
    "Subnet",
    "KeyVault",
    "StorageAccount",
    "AppServicePlan",
    "AzureFunctionApp"
)

#Connect to your Azure Account
Connect-AzAccount

    Write-Output "####################"
    Write-Output "Getting Resource Details"
    Write-Output "####################"

#Validate if the resource group exist
    $existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName}

if(!$existingRG){
    Write-Output "####################"
    Write-Output "Creating Resource Group"
    Write-Output "####################"
    
    try {
        #Create a variable with the name of the resource group
        $newRg= New-AzResourceGroup -Name $rgName -Location $location

       #Deploy an app service plan with ARM template
        $templateFileasp = "./appserviceplan.json"
        New-AzResourceGroupDeployment `
        -Name addappserviceplan `
        -ResourceGroupName $newRG.ResourceGroupName  `
        -TemplateFile $templateFileasp `

        #Deploy an storage account with ARM template
        $templateFilesa = "./storageaccount.json"
        New-AzResourceGroupDeployment `
        -Name addstorageaccount `
        -ResourceGroupName $newRG.ResourceGroupName  `
        -TemplateFile $templateFilesa `



    }
    catch {
        #Throw an exception in case the name of the resource group is not valid
        Throw "Deployment failed: $_"
    }
    
}

else{
    $hashtableParameters = @{
        storageAccountName = $storageAccountName
    }
    
    #Deploy the resourcen in the existing resource group name given
    $templateFileasp = "./appserviceplan.json"
    New-AzResourceGroupDeployment `
    -Name addappserviceplan `
    -ResourceGroupName $existingRG.ResourceGroupName  `
    -TemplateFile $templateFileasp `


    $templateFilesa = "./storageaccount.json"
    New-AzResourceGroupDeployment `
    -Name addoutputs `
    -ResourceGroupName $existingRG.ResourceGroupName  `
    -TemplateFile $templateFilesa `
}

