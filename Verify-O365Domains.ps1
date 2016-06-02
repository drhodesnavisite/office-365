#Run this to complete domain verification

Get-MsolDomain -TenantId $tenantId | Where-Object {$_.Status -eq "Unverified"} | ForEach-Object {Confirm-MsolDomain -domainname $_.name -TenantId $tenantId}