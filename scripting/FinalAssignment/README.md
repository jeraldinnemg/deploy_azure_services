# Final Assessment M2 & M3

## Descripción

Script desatendido que le permite al usuario crear o borrar recursos de Azure.

## Objetivo

1. Armar un script en PowerShell que haga un deploy de los recursos que seleccione el usuario de la siguiente lista mediante, al menos, 4 ARM templates:
    - Resource Group
    - Network Security Group
    - Virtual Network
    - Subnet
    - Key Vault
    - Storage Account
    - Virtual Machine (Opcional - tener en cuenta los créditos disponibles para no agotarlos)
    - App Service Plan
    - Azure Function App
 
2. El script también deberá ser capaz de borrar estos recursos
 
3. Para cumplir con los primeros dos puntos, el script deberá estar parametrizado. Cada parámetro corresponderá al nombre de un recurso e indicará si los mismos se crearán o se destruirán. Por ejemplo, si el usuario quisiera hacer un deploy de un Resource Group + una Virtual Network, debería pasar los parámetros "-Create", "-RGName" y "VNetName"

4. Los nombres de los archivos podrían ser leídos desde un archivo adicional (Opcional)
 
5. El script deberá realizar las siguientes validaciones:
    - Validar que el nombre elegido esté disponible
    - Validar que el nombre elegido corresponda con la [naming convention](https://explore.eyfabric.ey.com/eydx/content/70e3f2c2-b810-4e25-9abf-5832fc6a1cd8?section=community&repoName=EY-Fabric-Everest#)
    - Validar que el recurso se haya creado/destruido según corresponda
    - Validar el uso correcto de los recursos. Por ejemplo, para deployar una Subnet, siempre deberá existir una Virtual Network
 
6. El script deberá contar con un error handling apropiado (Try - Catch)
 
7. El script deberá loggear los pasos y guardarlos en un archivo para facilitarle la lectura y el funcionamiento al usuario. Por ejemplo, loggear cuando se esté deployando o borrando un recurso
 
8. El script deberá al finalizar la ejecución mostrar y exportar a un archivo todos los resources ID generados o borrados

## Características

* Crea los nombres de cada recurso si el usuario no los especifica

* Crea todos los recursos de la lista si el usuario no especifica el tipo de recurso

* Borra los recursos creados anteriormente si el usuario no especifica el nombre del recurso

* Borra todos los resource group de una suscripción

## Construido con

<font>✅</font> [PowerShell](https://learn.microsoft.com/en-us/powershell/)

<font>✅</font> [Azure](https://azure.microsoft.com/en-us/)

## Versionado

[GitHub](https://github.com/)

## Instrucciones de instalación y configuración

<font color="#FFE600">⚠</font> Necesitas:

<font color="#2DB757">✔</font> [Visual Studio Code](https://code.visualstudio.com/)

<font color="#2DB757">✔</font> [Extensión de PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)

<font color="#2DB757">✔</font> [Suscripción de Azure](https://portal.azure.com)

<font color="#2DB757">✔</font> [Git](https://git-scm.com/) v2.31.1 instalado globalmente en tu máquina

1. Abrir VSC y la terminal integrada de Git Bash

2. Clonar este repositorio remoto con el comando `git clone https://github.com/arielm86/acd-scripting.git`

3. Acceder a la carpeta, del ahora repositorio local, con el comando `cd acd-scripting`

4. Moverse a la rama de nuestro equipo con el comando `git checkout grupo5/master`

5. Seleccionar la terminal de PowerShell y ejecutar el script y pasarle los parámetros para crear o borrar los recursos que quieras.

6. Guiarse por el archivo log para verificar el estado de los recursos.

## Parámetros

* Para indicar la acción, es necesario el siguiente paramétro, que acepta uno de los dos valores string<br>
    -Action "create"<br>
    -Action "delete"<br>

* Para crear recursos, son necesarios los siguientes parámetros switch, que al ejecutarlos toman como valor $true<br>
    -All<br>
    -ResourceGroup<br>
    -NetworkSecurityGroup<br>
    -VirtualNetwork<br>
    -Subnet<br>
    -KeyVault<br>
    -StorageAccount<br>
    -AppServicePlan<br>
    -AzureFunctionApp<br>

* Para borrar y si se quiere especificar el nombre del recurso, son necesarios los siguientes parámetros, que aceptan como valor un string<br>
    -ResourceGroupName ""<br>
    -NetworkSecurityGroupName ""<br>
    -VirtualNetworkName ""<br>
    -SubnetName ""<br>
    -KeyVaultName ""<br>
    -StorageAccountName ""<br>
    -AppServicePlanName ""<br>
    -AzureFunctionAppName ""<br>

## Casos de uso

* Deploya los 7 recursos en un mismo resource group con nombres autogenerados<br>
`.\script.ps1 -Action "create"`

* Deploya el/los recursos indicados con un nombre autogenerado<br>
`.\script.ps1 -Action "create" -KeyVault -StorageAccount`

* Deploya el/los recursos indicado con un nombre definido por el usuario<br>
`.\script.ps1 -Action "create" -Subnet -SubnetName "AZUSEDT8JK9OSBNG7"`

* Deploya el/los recursos indicados dentro de ese mismo resource group<br>
`.\script.ps1 -Action "create" -NetworkSecurityGroup -ResourceGroup -ResourceGroupName "AZUSED0PF67WRSGH9"`

* Borra solo el resource group que se creó previamente<br>
`.\script.ps1 -Action "delete"`

* Borra todos los resource group de la suscripción<br>
`.\script.ps1 -Action "delete" -All`

* Borra el/los recursos (y sus hijos) especificados con su nombre<br>
`.\script.ps1 -Action "delete" -VirtualNetworkName "AZUSED5YJ82QVNTZZ" -AppServicePlanName "AZUSEDRH765LASP1F"`

## Autoras

Desarrollado por: [Alessandra D Bolivar](https://www.linkedin.com/in/alessandra-bolivar-598944242/), [Constanza Pugliese](https://www.linkedin.com/in/constanzapugliese/), [Jeraldinne Molleda](https://www.linkedin.com/in/jeraldinne-molleda/) y [Sasha A Moiguer](https://www.linkedin.com/in/sasha-moiguer/)