If ($PathIsWebApp -eq $True) {
    Try 
    {
      $ContainsApplicationFiles = "$((Get-ChildItem $Path).Extension | Sort-Object -Unique)" -match  '\.js|\.html|\.css'
 
      If ( -Not $ContainsApplicationFiles) {
        Throw "Not a web app"
      } Else {
        Write-Host "Source files look good, continuing"
      }
    } Catch {
     Throw "No backup created due to: $($_.Exception.Message)"
    }
 }