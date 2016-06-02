$roleGroupName = Read-Host "Enter Name of Role Group:"
$roleGroupRoles = (Get-RoleGroup "Recipient Management").Roles
$roleGroupMembers = @()
do {
 $input = (Read-Host "Enter email address of user to add to $roleGroupName")
 if ($input -ne '') {$roleGroupMembers += $input}
}
until ($input -eq '')

New-RoleGroup -Name "$roleGroupName" -Roles $roleGroupRoles -Members $roleGroupMembers

Write-Host "$roleGroupMembers have been added to the $roleGroupName Role Group"