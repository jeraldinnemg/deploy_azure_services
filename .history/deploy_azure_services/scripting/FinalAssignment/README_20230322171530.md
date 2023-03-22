# Final Assessment M2 & M3

## Description

Unattended script that allows the user to create or delete Azure resources.

## Objetive

1. Build a PowerShell script that deploys the resources selected by the user from the following list using at least 4 ARM templates:
    - Resource Group
    - Network Security Group
    - Virtual Network
    - Subnet
    - Key Vault
    - Storage Account
    - Virtual Machine (Optional - taking into account available credits to avoid running out)
    - App Service Plan
    - Azure Function App

2.The script should also be capable of deleting these resources.

3. To accomplish the first two objectives, the script must be parameterized. Each parameter will correspond to the name of a resource and indicate whether it will be created or destroyed. For example, if the user wanted to deploy a Resource Group + a Virtual Network, they should pass the parameters "-Create", "-RGName" and "VNetName".

4. The file names could be read from an additional file (optional).

5. The script must perform the following validations:
    - Validate that the chosen name is available
    - Validate that the chosen name corresponds to the naming convention
    - Validate that the resource has been created/destroyed as appropriate
    - Validate the correct use of resources. For example, to deploy a Subnet, there must always be a Virtual Network

6. The script should have appropriate error handling (Try-Catch)

7. The script should log the steps and save them to a file to facilitate reading and operation by the user. For example, log when a resource is being deployed or deleted.

8. At the end of execution, the script should display and export to a file all the resource IDs generated or deleted.

## Features

* Generates names for each resource if the user does not specify them.

* Creates all the resources in the list if the user does not specify the resource type.

* Deletes previously created resources if the user does not specify the resource name.

* Deletes all resource groups in a subscription.

## Built with

<font>✅</font> [PowerShell](https://learn.microsoft.com/en-us/powershell/)

<font>✅</font> [Azure](https://azure.microsoft.com/en-us/)

## Versioning

[GitHub](https://github.com/)

## Installation and configuration:

<font color="#FFE600">⚠</font> You need to install: 

<font color="#2DB757">✔</font> [Visual Studio Code](https://code.visualstudio.com/)

<font color="#2DB757">✔</font> [PowerShell Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)

<font color="#2DB757">✔</font> [Azure Subscription](https://portal.azure.com)

<font color="#2DB757">✔</font> [Git](https://git-scm.com/) v2.31.1 


1. Open VSC and the Git Bash integrated terminal.

2. Clone this remote repository with the command `git clone https://github.com/arielm86/acd-scripting.git`

3. Access the folder of the now local repository with the command `cd acd-scripting`

4. Move to our team's branch with the command `git checkout grupo5/master`

5. Select the PowerShell terminal and run the script passing the parameters to create or delete the desired resources.

6. Follow the log file to verify the state of the resources.

## Parameters

* To indicate the action, the following parameter is required, which accepts one of two string values: <br>
    -Action "create"<br>
    -Action "delete"<br>

* To create resources, the following switch parameters are required, which when executed take the value $true:<br>
    -All<br>
    -ResourceGroup<br>
    -NetworkSecurityGroup<br>
    -VirtualNetwork<br>
    -Subnet<br>
    -KeyVault<br>
    -StorageAccount<br>
    -AppServicePlan<br>
    -AzureFunctionApp<br>

* To delete and if you want to specify the name of the resource, the following parameters are required, which accept a string value:<br>
    -ResourceGroupName ""<br>
    -NetworkSecurityGroupName ""<br>
    -VirtualNetworkName ""<br>
    -SubnetName ""<br>
    -KeyVaultName ""<br>
    -StorageAccountName ""<br>
    -AppServicePlanName ""<br>
    -AzureFunctionAppName ""<br>

## Use Cases

* Deploy the 7 resources in the same resource group with auto-generated names:<br>
`.\appscript.ps1 -Action "create"`

* Deploy the indicated resource(s) with an auto-generated name: <br>
`.\appscript.ps1 -Action "create" -KeyVault -StorageAccount`

* Deploy the indicated resource(s) with a name defined by the user: <br>
`.\appscript.ps1 -Action "create" -Subnet -SubnetName "AZUSEDT8JK9OSBNG7"`

* Deploya el/los recursos indicados dentro de ese mismo resource group<br>
`.\appscript.ps1 -Action "create" -NetworkSecurityGroup -ResourceGroup -ResourceGroupName "AZUSED0PF67WRSGH9"`

* Delete only the resource group that was previously created: <br>
`.\appscript.ps1 -Action "delete"`

* Delete all the resource groups in the subscription: <br>
`.\appscript.ps1 -Action "delete" -All`

* Delete the indicated resource(s) (and their children) by their name: <br>
`.\appscript.ps1 -Action "delete" -VirtualNetworkName "AZUSED5YJ82QVNTZZ" -AppServicePlanName "AZUSEDRH765LASP1F"`

## Authors

Developed by: [Alessandra D Bolivar](https://www.linkedin.com/in/alessandra-bolivar-598944242/), [Constanza Pugliese](https://www.linkedin.com/in/constanzapugliese/), [Jeraldinne Molleda](https://www.linkedin.com/in/jeraldinne-molleda/) y [Sasha A Moiguer](https://www.linkedin.com/in/sasha-moiguer/)