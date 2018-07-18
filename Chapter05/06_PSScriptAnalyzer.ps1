# On PS Gallery
Install-Module PSScriptAnalyzer -Force

Get-Command -Module PSScriptAnalyzer

# this triggers the analyzer
# Aliases should not be used
Get-Process | Where Name -eq explorer

# this also triggers a rule
# Variables that are not consumed should be removed
$var = "test"

Invoke-ScriptAnalyzer -Path .\Ch5\06_PSScriptAnalyzer.ps1

# you can exclude specific rules
# The argument completer should give you a list of all rules
Invoke-ScriptAnalyzer -Path .\Ch5\06_PSScriptAnalyzer.ps1 -ExcludeRule PSAvoidUsingCmdletAliases

# When writing functions, you can suppress rules as well
function Get-Stuff()
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="I want to write to the console host!")]
    param()

    Write-Host 'There are no comments here...'

}

Invoke-ScriptAnalyzer -Path .\Ch5\06_PSScriptAnalyzer.ps1