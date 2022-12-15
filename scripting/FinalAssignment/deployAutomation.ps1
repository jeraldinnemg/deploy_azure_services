#Define parameters of the RG
param(
    [Parameter(Mandatory)]$rgName,
    [Parameter(Mandatory)]$location
)

#Connecto to Azure Account
Connect-AzAccount
    Write-Output "####################"
    Write-Output "Getting Resource Details"
    Write-Output "####################"

    #Validate if the name given is available
    $existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName}

    #Validate if the name given is according to the EY naming convention
    function Validate-AzureResourceName
    {
      # Get the na
      [CmdletBinding()]
      param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$rgName
      )
    
      # Regular expression(regex) to validate the naming convention:
      # <Cloud provider 2 chars>-<Location 3 chars>-<Environment 1 char>-<DeploymentID 6 chars>-<Resource Type 3 chars>-<Sequence 2 chars>
      # Valid name example: az-eus-d-001122-rg-01 / Invalid name example: az-eus-d-001122-vm-001
      [regex]$rx = ('^[a-zA-Z]{2}-[a-zA-Z]{3}-[a-zA-Z]{1}-[a-zA-Z0-9]{6}-[a-zA-Z0-9]{3}-[a-zA-Z0-9]{2}$')

    }
    

    #If there isn't a resource group with the name given, create the RG
if(!$existingRG){
    Write-Output "####################"
    Write-Output "Creating Resource Group"
    Write-Output "####################"
    
    try {
        #Define the resourceGroup in a variable
        Validate-AzureResourceName -Name $rgName
         # Validation of the name given with regex
        if ($regex.IsMatch($rGName))
        {
            $newRg= New-AzResourceGroup -Name $rgName -Location $location

            #Create a resource group with the RG variable as a parameter, and deploy the ARM template of the resource "desired"
            New-AzResourceGroupDeployment -ResourceGroupName $newRG.ResourceGroupName -TemplateFile "./storageDeploy.json"
        }
       
    }
    catch {
        Throw "Deployment failed: $_"
    }
}
else{
    New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -TemplateFile "./storageDeploy.json"
}