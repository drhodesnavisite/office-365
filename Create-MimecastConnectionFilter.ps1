Get-HostedConnectionFilterPolicy > C:\$tenantDomain"_ConnectionFilter.txt"
Enable-OrganizationCustomization
Write-Host "Sleeping for 60 seconds..."
Start-Sleep -Seconds 60
New-HostedConnectionFilterPolicy -Name "Mimecast Inbound" -IPAllowList 207.211.31.0/25,207.211.30.0/24,205.139.110.0/24,205.139.111.0/24,216.205.24.0/24,63.128.21.0/24,205.217.25.135/32,205.217.25.132/32,207.211.41.113/32 -EnableSafeList $true