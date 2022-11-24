Try {
    If ($Path -eq './forbidden') 
    {
      Throw "Path not allowed"
    }
    # Carry on.
 git
 } Catch {
    Write-Error "$($_.exception.message)" # Path not allowed.
 }

