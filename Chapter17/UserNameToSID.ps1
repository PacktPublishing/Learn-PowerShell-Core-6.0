$domain = 'exampleDomain'
$username = 'User01'

$sid = (New-Object Security.Principal.NTAccount($domain, $username)).Translate([Security.Principal.SecurityIdentifier]).Value

$sid


$username = 'Administrator'

$sid = (New-Object Security.Principal.NTAccount($env:computername, $username)).Translate([Security.Principal.SecurityIdentifier]).Value

$sid