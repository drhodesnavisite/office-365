$SharedMailboxes = Get-Content SharedMailboxes.txt
$LicenseToAssign = #License Here (e.g. reseller-account:ENTERPRISEPACK)

$SharedMailboxes | ForEach {
    Set-MsolUserLicense -UserPrincipalName $_ -TenantId $tenantId -AddLicenses $LicenseToAssign
    $Mailbox = Get-Mailbox $_
    Do {
        $MailboxExists = [bool](Get-Mailbox $_ -ErrorAction SilentlyContinue)
        Write-Host "Checking if Mailbox for $Mailbox exists."
        $MailboxExists
        Write-Host "Waiting for $Mailbox to be created."
        } While ($MailboxExists -eq $False)
    Write-Host "Found Mailbox for $Mailbox. Converting to Shared Mailbox."
    Set-Mailbox $_ -Type Shared
    Do {
        $MailboxIsShared = [bool](Get-Mailbox $_ | ? {$_.RecipientTypeDetails -eq "SharedMailbox"} -ErrorAction SilentlyContinue)
        Write-Host "Checking if $Mailbox has been converted to a Shared Mailbox."
        $MailboxIsShared
        Write-Host "Waiting for $Mailbox to be converted."
        } While ($MailboxIsShared -eq $False)
    Write-Host "$Mailbox has been converted to a Shared Mailbox.  Reclaiming license."
    $LicenseToRemove = (Get-MsolUser -UserPrincipalName $_ -TenantId $tenantId).Licenses.AccountSkuID
    Set-MsolUserLicense -UserPrincipalName $_ -TenantId $tenantId -RemoveLicenses $LicenseToRemove
}

