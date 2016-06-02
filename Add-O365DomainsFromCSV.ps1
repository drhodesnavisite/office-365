#Run this to populate domains and generate TXT records file

$domains = import-csv .\domains.csv                                                
$txtrecord = @()
                                                               
foreach($domain in $domains){                                                    
    New-MsolDomain -Name $domain.domain -TenantId $tenantId                                             
    $txtrecord += (Get-MsolDomainVerificationDNS -DomainName $domain.domain -mode dnstxtrecord -TenantId $tenantId)        
}                                                                        

$txtrecord | Select-Object text,label,ttl | Export-Csv C:\txtrecord.csv