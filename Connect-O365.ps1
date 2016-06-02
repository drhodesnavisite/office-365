CLS
Set-ExecutionPolicy RemoteSigned
Import-Module SkypeOnlineConnector

[int]$menuChoice = 0
while ( $menuChoice -lt 1 -or $menuChoice -gt 3 ){
    Write-Host "1. Connect directly to Office 365 tenant"
    Write-Host "2. Manage Office 365 tenant using delegated access (CSP)"
    Write-Host "3. Disconnect PowerShell Sessions"
[Int]$menuChoice = Read-Host "Please enter an option 1 to 3..." }

Switch( $menuChoice ){
  1{
    $credential = Get-Credential

    Import-Module MsOnline
    Connect-MsolService -Credential $credential

    $tenantDomain = (Get-MsolDomain | ? {$_.IsDefault -eq $true}).Name
    $tenantName = (Get-MsolCompanyInformation).DisplayName

    $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
    Import-PSSession $exchangeSession -DisableNameChecking

    $ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.compliance.protection.outlook.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
    Import-PSSession $ccSession -DisableNameChecking

    $sfboSession = New-CsOnlineSession -Credential $credential
    Import-PSSession $sfboSession

    $pos = $tenantDomain.IndexOf(".onmicrosoft.com")
    $tenantDomainPart = $tenantDomain.Substring(0,$pos)
    Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
    Connect-SPOService -Url https://$tenantDomainPart-admin.sharepoint.com -credential $credential

    $host.UI.RawUI.WindowTitle = "$tenantName ($tenantDomain) - Managed By " + $credential.UserName
    CLS
    Write-Host "You are currently managing $tenantName directly."
  }

  2{
    $credential = Get-Credential

    Import-Module MsOnline
    Connect-MsolService -Credential $credential

    $searchString = Read-Host "Enter unique string for customer name"
    $tenantDomain = (Get-MsolPartnerContract -all | where {$_.Name -like "*$searchString*"}).DefaultDomainName
    $tenantId = (Get-MsolPartnerContract -all | where {$_.Name -like "*$searchString*"}).TenantId.Guid
    $tenantName = (Get-MsolPartnerContract -all | where {$_.Name -like "*$searchString*"}).Name
    
    $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid?DelegatedOrg=$tenantDomain" -Credential $credential -Authentication "Basic" -AllowRedirection
    Import-PSSession $exchangeSession -DisableNameChecking

    #$ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.compliance.protection.outlook.com/powershell-liveid?DelegateOrg=$tenantDomain" -Credential $credential -Authentication "Basic" -AllowRedirection
    #Import-PSSession $ccSession -DisableNameChecking

    $sfboSession = New-CsOnlineSession -Credential $credential -OverrideAdminDomain $TenantDomain
    Import-PSSession $sfboSession

    #$pos = $tenantDomain.IndexOf(".onmicrosoft.com")
    #$tenantDomainPart = $tenantDomain.Substring(0,$pos)
    #Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
    #Connect-SPOService -Url https://$tenantDomainPart-admin.sharepoint.com -credential $credential

    $host.UI.RawUI.WindowTitle = "$tenantName ($tenantDomain) - Managed By " + $credential.UserName
    CLS
    Write-Host "You are currently managing $tenantName.  Remember to use the -TenantID switch for all MSOL cmdlets."
  }

  3{
    Get-PSSession | Remove-PSSession
    $host.UI.RawUI.WindowTitle = "No Active Sessions"
    CLS
    Write-Host "You are currently disconnected from all PS Sessions"
  }

default{}

}
