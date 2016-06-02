#Populate Variables
$searchString = Read-Host "Enter unique string for customer name"
$tenantDomain = (Get-MsolPartnerContract -all | where {$_.Name -like "*$searchString*"}).DefaultDomainName
$tenantId = (Get-MsolPartnerContract -all | where {$_.Name -like "*$searchString*"}).TenantId.Guid
$DirSyncPassword = Read-Host "Enter DirSync Service Account password (init...)"

#Create DirSync Account
New-MsolUser -DisplayName "NaviSite DirSync Svc Acct" -FirstName "NaviSite" -LastName "DirSync Service Acct" -UserPrincipalName dirsync@$tenantDomain -Password $DirSyncPassword -tenantID $tenantId

Start-Sleep -Seconds 30

#Prevent password change
Set-MsolUserPassword -UserPrincipalName dirsync@$tenantDomain -ForceChangePassword $false -NewPassword $DirSyncPassword -TenantId $tenantId

#Set password to not expire
Set-MsolUser -UserPrincipalName dirsync@$tenantDomain -PasswordNeverExpires $true -tenantID $tenantId

#Add to Global Admin role
Add-MsolRoleMember -RoleName "Company Administrator" -RoleMemberEmailAddress dirsync@$tenantDomain -tenantID $tenantId

#Enable DirSync
Set-MsolDirSyncEnabled -EnableDirSync $True -TenantId $tenantId

Start-Sleep -Seconds 60

#Check DirSync Status
Write-Host "DirSync Enabled:" (Get-MSOLCompanyInformation -TenantId $tenantId).DirectorySynchronizationEnabled