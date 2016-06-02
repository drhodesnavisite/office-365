$roleGroupName = "Company Administrator"
$roleMemberEmailAddress = Read-Host "Enter email address(es) to add to Company Administrator role:"

Add-MsolRoleMember -RoleName $roleGroupName -RoleMemberEmailAddress $roleMemberEmailAddress -TenantId $tenantId