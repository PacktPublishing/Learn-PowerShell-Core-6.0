# Setting up demo environment

#Creating 20 mail addresses / users:
1..20 | ForEach-Object {New-MailUser -Name "DemoUser$_" -MicrosoftOnlineServicesID DemoUser$_@demo.com -Password (ConvertTo-SecureString -String $_'Passwort1.' -AsPlainText -Force) -ExternalEmailAddress "DemoUser$_@demo.com"}

#Creating 20 contacts:
1..20 | ForEach-ObjectForEach-Object {New-Mailcontact -Name "Contact$_" -Externalemailaddress DemoUser$_@demo.com}

#Creating 3 distribution groups:
1..3 | ForEach-Object {New-DistributionGroup Distgrp$_}

#Adding members to distribution groups:
1..2 | ForEach-Object {Add-DistributionGroupMember Distgrp1 -Member DemoUser$_}
5 | ForEach-Object {Add-DistributionGroupMember Distgrp1 -Member DemoUser$_}
1..8 | ForEach-Object {Add-DistributionGroupMember Distgrp1 -Member contact$_}
8..15 | ForEach-Object {Add-DistributionGroupMember Distgrp2 -Member contact$_}
16..20 | ForEach-Object {Add-DistributionGroupMember Distgrp3 -Member contact$_}

#Creating dynamic distribution groups:
New-DynamicDistributionGroup Dyngrp1 -RecipientFilter {(customattribute10 -like "*1*")}
New-DynamicDistributionGroup Dyngrp1 -RecipientFilter {(customattribute10 -like "*2*")}

#Setting departments
1..5 | ForEach-Object {Set-User DemoUser$_ -department "Development"}
6..10 | ForEach-Object {Set-User DemoUser$_ -department "Marketing"}
11..15 | ForEach-Object {Set-User DemoUser$_ -department "Management"}
16..20 | ForEach-Object {Set-User DemoUser$_ -department "HR"}

#Adding custom attributes to contacts
1..5 | ForEach-Object {Set-MailContact contact$_ -CustomAttribute1 ConGrp1}
6..10 | ForEach-Object {Set-MailContact contact$_ -CustomAttribute1 ConGrp2}
11..15 | ForEach-Object {Set-MailContact contact$_ -CustomAttribute1 ConGrp3}
16..20 | ForEach-Object {Set-MailContact contact$_ -CustomAttribute1 ConGrp4}

#Modifying custom attributes for mailboxes:
1..5 | ForEach-Object {Set-Mailbox DemoUser$_ -CustomAttribute10 Grp1}
6..10 | ForEach-Object {Set-Mailbox DemoUser$_ -CustomAttribute10 Grp2}

#Changing time zones
1..6 | ForEach-Object {Set-MailboxCalendarConfiguration -id DemoUser$_ -WorkingHoursTimeZone "Central European Time"}
6..7 | ForEach-Object {Set-MailboxCalendarConfiguration -id DemoUser$_ -WorkingHoursTimeZone "Eastern Standard Time"}
8..11 | ForEach-Object {Set-MailboxCalendarConfiguration -id DemoUser$_ -WorkingHoursTimeZone "Pacific Standard Time"}
12..13 | ForEach-Object {Set-MailboxCalendarConfiguration -id DemoUser$_ -WorkingHoursTimeZone "Central European Time"}
14..16 | ForEach-Object {Set-MailboxCalendarConfiguration -id DemoUser$_ -WorkingHoursTimeZone "Eastern Standard Time"}
17..20 | ForEach-Object {Set-MailboxCalendarConfiguration -id DemoUser$_ -WorkingHoursTimeZone "Pacific Standard Time"}

#Filtering and setting offices
Get-Mailbox | Get-MailboxCalendarConfiguration | Where-Object {$_.WorkingHoursTimeZone -eq "Central European Time"} | Set-User -Office "Munich"
Get-Mailbox | Get-MailboxCalendarConfiguration | Where-Object {$_.WorkingHoursTimeZone -eq "Eastern Standard Time"} | Set-User -Office "Ohio"
Get-Mailbox | Get-MailboxCalendarConfiguration | Where-Object {$_.WorkingHoursTimeZone -eq "Pacific Standard Time"} | Set-User -Office "Seattle"

