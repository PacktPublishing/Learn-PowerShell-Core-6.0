#region Help content, Help system
read-host
# No help content since PSv3
Update-Help # Only the first execution each day is processed

# Prestage help content for internal distribution
Save-Help -DestinationPath .\HelpContent
Update-Help -SourcePath .\HelpContent

# If really necessary, Update- and Save-Help support a UICulture
Save-Help -DestinationPath .\HelpContent -UICulture de-de

#endregion

#region help-driven development

function Get-CommentBasedHelp {
    <#
        .SYNOPSIS
            This contains a brief description
        .DESCRIPTION
            This contains a long description
        .EXAMPLE
            Get-CommentBasedHelp

            These are examples for all parameter sets
        .NOTES
            This contains additional fluff like the author, changelog, ...
    #>
    [CmdletBinding()]
    param(
        # This is a parameter description
        [Parameter(Mandatory=$true)]
        [String]$SomeParameter
    )

}
Get-Help Get-CommentBasedHelp
Get-Help Get-CommentBasedHelp -Examples
Get-Help Get-CommentBasedHelp -Parameter SomeParameter

# Help with PlatyPS
Install-Module PlatyPS -Scope CurrentUser -Force

New-Module -Name OnTheFly -ScriptBlock {function Get-Stuff {param([Parameter(Mandatory)]$SomeParameter)}}

# Generate help for all exported functions
New-MarkdownHelp -Module OnTheFly -OutputFolder .\PlatyPSHelp
psedit .\PlatyPSHelp\Get-Stuff.md

# Generate generic help (See get-help about_* for those topics)
New-MarkdownAboutHelp -OutputFolder .\PlatyPSHelp -AboutName StringTheory
psedit .\PlatyPSHelp\about_StringTheory.md
#endregion