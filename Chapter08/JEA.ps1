# Possible cmdlets for first-level user admin

# Modify user passwords only in specific search bases
$account = Get-ADUser -SearchBase 'OU=Users,OU=DepartmentXY,DC=contoso,DC=com' -SearchScope Subtree -Identity neilgaiman

$password = Read-Host -AsSecureString -Prompt 'Password please'
Set-ADAccountPassword -NewPassword $password -Identity $account

# Modify group memberships only for specific OUs
Add-AdGroupMember -Identity "CN=groupName,OU=DepartmentXY,DC=contoso,DC=com" -Members account1, account2, account3
Get-AdGroupMember -Identity "CN=groupName,OU=DepartmentXY,DC=contoso,DC=com"

# Modify permissions only in certain paths
Add-NTFSAccess -Path \\namespace\groupshare\groupfolder -Account contoso\GroupAccount

# Get service status
Get-Service -Name spooler

# Hiding complexity
function Get-DepartmentAdUser
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $DepartmentName,

        [Parameter(Mandatory)]
        [string]
        $UserName
    )

    Get-ADUser -SearchBase "OU=Users,OU=$DepartmentName,DC=contoso,DC=com" -SearchScope Subtree -Identity $UserName
}

function Add-DepartmentAdGroupMember
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $DepartmentName,

        [Parameter(Mandatory)]
        [string]
        $GroupName,

        [Parameter(Mandatory)]
        [string[]]
        $MemberName
    )

    Add-AdGroupMember -Identity "CN=$GroupName,OU=$DepartmentName,DC=contoso,DC=com" -Members $MemberName
}

function Get-DepartmentAdGroupMember
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $DepartmentName,

        [Parameter(Mandatory)]
        [string]
        $GroupName
    )

    Get-AdGroupMember -Identity "CN=$GroupName,OU=$DepartmentName,DC=contoso,DC=com"
}


# Creating new role capabilities

# While all properties can be filled through cmdlet parameters
# it is usually easier to edit the file manually
$roleCapabilityOptions = @{
    Path                = '.\FirstLevelUserSupport.psrc'
    Description         = 'Provides first level support access to change user passwords'
    VisibleCmdlets      = @(
        @{
            Name       = 'Get-Service'
            Parameters = @{
                Name        = 'Name'
                ValidateSet = 'Spooler'
            }
        }
        @{
            Name       = 'Add-NTFSAccess'
            Parameters = @{
                Name            = 'Path'
                ValidatePattern = '\\\\namespace\\groupshare\\Group.*'
            },
            @{ Name = 'Account'},
            @{Name = 'AccessRights'},
            @{Name = 'AccessType'},
            @{Name = 'InheritanceFlags'},
            @{Name = 'PropagationFlags'}
        }
        'Read-Host'
    )
    VisibleFunctions    = 'Get-DepartmentAdUser', 'Get-DepartmentAdGroupMember', 'Add-DepartmentAdGroupMember'
    FunctionDefinitions = @{
        Name        = 'Get-DepartmentAdUser'        
        ScriptBlock = {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [string]
                $DepartmentName,
        
                [Parameter(Mandatory)]
                [string]
                $UserName
            )
        
            Get-ADUser -SearchBase "OU=Users,OU=$DepartmentName,DC=contoso,DC=com" -SearchScope Subtree -Identity $UserName
        }
    },
    @{
        Name        = 'Get-DepartmentAdGroupMember' 
        ScriptBlock = {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [string]
                $DepartmentName,
        
                [Parameter(Mandatory)]
                [string]
                $GroupName
            )
        
            Get-AdGroupMember -Identity "CN=$GroupName,OU=$DepartmentName,DC=contoso,DC=com"
        }
    },
    @{
        Name        = 'Add-DepartmentAdGroupMember' 
        ScriptBlock = {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [string]
                $DepartmentName,
        
                [Parameter(Mandatory)]
                [string]
                $GroupName,
        
                [Parameter(Mandatory)]
                [string[]]
                $MemberName
            )
        
            Add-AdGroupMember -Identity "CN=$GroupName,OU=$DepartmentName,DC=contoso,DC=com" -Members $MemberName
        }
    }
}

New-PSRoleCapabilityFile @roleCapabilityOptions

# Merging role capabilities

# Cmdlets/functions in one capability
$capA = @{VisibleCmdlets = 'Get-Process'}
$capB = @{}
$merge = @{VisibleCmdlets = 'Get-Process'}

# Cmdlets/functions in muliple capabilities
$capA = @{VisibleCmdlets = 'Get-Process'; Parameters = @{Name = 'Name'}}
$capB = @{VisibleCmdlets = 'Get-Process'}
$merge = @{VisibleCmdlets = 'Get-Process'}

$capA = @{VisibleCmdlets = 'Get-Process'; Parameters = @{Name = 'Name'}}
$capB = @{VisibleCmdlets = 'Get-Process'; Parameters = @{Name = 'Id'}}
$merge = @{VisibleCmdlets = 'Get-Process'; Parameters = @{Name = 'Name'},@{Name = 'Id'}}

# Validation in multiple roles
$capA = @{VisibleCmdlets = 'Get-Process'; Parameters = @{Name = 'Name'; ValidateSet='A','B'}}
$capB = @{VisibleCmdlets = 'Get-Process'; Parameters = @{Name = 'Name'; ValidateSet='C'}}
$merge = @{VisibleCmdlets = 'Get-Process'; Parameters = @{Name = 'Name'; ValidateSet='A','B''C'}}


# Session configurations

# Again, it is easier to edit the file manually
$sessionConfigurationOptions = @{
    Path                = '.\SessionConfig.pssc'
    SessionType         = 'RestrictedRemoteServer'
    TranscriptDirectory = 'C:\Transcripts'
    RunAsVirtualAccount = $true
    LanguageMode        = 'ConstrainedLanguage'
    RoleDefinitions     = @{
        'contoso\FirstLevelSupport' = @{RoleCapabilities = 'FirstLevelUserSupport'}
    }
}

New-PSSessionConfigurationFile @sessionConfigurationOptions

# The user drive
$sessionConfigurationOptions = @{
    Path                 = '.\SessionConfig.pssc'
    SessionType          = 'RestrictedRemoteServer'
    TranscriptDirectory  = 'C:\Transcripts'
    RunAsVirtualAccount  = $true
    LanguageMode         = 'ConstrainedLanguage'
    MountUserDrive       = $true
    UserDriveMaximumSize = 50MB
}

New-PSSessionConfigurationFile @sessionConfigurationOptions
Register-PSSessionConfiguration -Name WithUserDrive -Path .\SessionConfig.pssc

$session = New-PSSession -ComputerName localhost -ConfigurationName WithUserDrive
'it just works' | Set-Content .\JeaTest.file
Copy-Item -ToSession $session -Path .\JeaTest.file -Destination user:\JeaTest.file
Copy-Item -FromSession $session -Path user:\JeaTest.file -Destination .\JeaTestFromConstrainedSession.file

# Register an individual session configuration

$roleCapabilitiesFolder = New-Item -Path (Join-Path ($env:PSModulePath -split ';')[1] 'JeaCapabilities\RoleCapabilities') -ItemType Directory -Force
$roleCapabilityOptions = @{
    Path                = Join-Path $roleCapabilitiesFolder 'FirstLevelUserSupport.psrc'
    Description         = 'Provides first level support access to change user passwords'
    VisibleCmdlets      = @(
        @{
            Name       = 'Get-Service'
            Parameters = @{
                Name        = 'Name'
                ValidateSet = 'Spooler'
            }
        }
        @{
            Name       = 'Add-NTFSAccess'
            Parameters = @{
                Name            = 'Path'
                ValidatePattern = '\\\\namespace\\groupshare\\Group.*'
            },
            @{ Name = 'Account'},
            @{Name = 'AccessRights'},
            @{Name = 'AccessType'},
            @{Name = 'InheritanceFlags'},
            @{Name = 'PropagationFlags'}
        }
        'Read-Host'
    )
    VisibleFunctions    = 'Get-DepartmentAdUser', 'Get-DepartmentAdGroupMember', 'Add-DepartmentAdGroupMember'
    FunctionDefinitions = @{
        Name        = 'Get-DepartmentAdUser'        
        ScriptBlock = {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [string]
                $DepartmentName,
        
                [Parameter(Mandatory)]
                [string]
                $UserName
            )
        
            Get-ADUser -SearchBase "OU=Users,OU=$DepartmentName,DC=contoso,DC=com" -SearchScope Subtree -Identity $UserName
        }
    },
    @{
        Name        = 'Get-DepartmentAdGroupMember' 
        ScriptBlock = {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [string]
                $DepartmentName,
        
                [Parameter(Mandatory)]
                [string]
                $GroupName
            )
        
            Get-AdGroupMember -Identity "CN=$GroupName,OU=$DepartmentName,DC=contoso,DC=com"
        }
    },
    @{
        Name        = 'Add-DepartmentAdGroupMember' 
        ScriptBlock = {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [string]
                $DepartmentName,
        
                [Parameter(Mandatory)]
                [string]
                $GroupName,
        
                [Parameter(Mandatory)]
                [string[]]
                $MemberName
            )
        
            Add-AdGroupMember -Identity "CN=$GroupName,OU=$DepartmentName,DC=contoso,DC=com" -Members $MemberName
        }
    }
}

New-PSRoleCapabilityFile @roleCapabilityOptions

# Session configurations

# Again, it is easier to edit the file manually
$sessionConfigurationOptions = @{
    Path                = '.\SessionConfig.pssc'
    SessionType         = 'RestrictedRemoteServer'
    TranscriptDirectory = 'C:\Transcripts'
    RunAsVirtualAccount = $true
    LanguageMode        = 'ConstrainedLanguage'
    RoleDefinitions     = @{
        'contoso\FirstLevelSupport' = @{RoleCapabilities = 'FirstLevelUserSupport'}
    }
}

New-PSSessionConfigurationFile @sessionConfigurationOptions

Register-PSSessionConfiguration -Path .\SessionConfig.pssc -Name SupportSession

# Distibuted session configuration
$sessions = New-PSSession -ComputerName (1..10 | % { "Node$_"})
$path = (Join-Path ($env:PSModulePath -split ';')[1] 'JeaCapabilities')
foreach ($session in $sessions)
{
    Copy-Item -Path $path -Destination $path -Recurse -ToSession $session -Force
}

Invoke-Command -Session $sessions -ScriptBlock {
    $sessionConfigurationOptions = @{
        Path                = '.\SessionConfig.pssc'
        SessionType         = 'RestrictedRemoteServer'
        TranscriptDirectory = 'C:\Transcripts'
        RunAsVirtualAccount = $true
        LanguageMode        = 'ConstrainedLanguage'
        RoleDefinitions     = @{
            'contoso\FirstLevelSupport' = @{RoleCapabilities = 'FirstLevelUserSupport'}
        }
    }
    
    New-PSSessionConfigurationFile @sessionConfigurationOptions
    
    Register-PSSessionConfiguration -Path .\SessionConfig.pssc -Name SupportSession -Force
}

# Deployment with DSC
configuration JeaEndpointConfiguration
{
    param
    (
        [string[]]$ComputerName
    )
    Import-DscResource -ModuleName JustEnoughAdministration

    node $ComputerName
    {

        File RoleCapabilities
        {
            SourcePath      = '\\contoso.com\ReadOnlyShare\JeaCapabilities'
            DestinationPath = (Join-Path ($env:PSModulePath -split ';')[1] 'JeaCapabilities')
            Ensure          = 'Present'
            Recurse         = $true
            Force           = $true
        }

        JeaEndpoint EndpointConfiguration
        {
            EndpointName        = 'SupportSession'
            RoleDefinitions     = '@{"contoso\FirstLevelSupport" = @{RoleCapabilities = "FirstLevelUserSupport"}}'
            DependsOn           = '[File]RoleCapabilities'
            Ensure              = 'Present'
            TranscriptDirectory = 'C:\Transcripts'
        }
    }
}

# Create MOF files
JeaEndpointConfiguration -ComputerName (1..10 | % { "Node$_"})
Start-DscConfiguration -Path .\JeaEndpointConfiguration -Wait -Verbose