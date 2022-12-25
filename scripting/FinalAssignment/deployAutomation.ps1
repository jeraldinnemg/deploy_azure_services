param(

    [Parameter(Mandatory)]$rgName,
    $location = "eastus",
    [Parameter(Mandatory)]$storageAccountName

)

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