function Show-OpenFileDialog
{
    <#
            .SYNOPSIS
            Shows up an open file dialog.
            .EXAMPLE
            Show-OpenFileDialog
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [System.String]
        $Title = 'Windows PowerShell',
        
        [Parameter(Mandatory=$false, Position=1)]
        [Object]
        $InitialDirectory = "$Home\Documents",
        
        [Parameter(Mandatory=$false, Position=2)]
        [System.String]
        $Filter = 'PowerShell-files|*.ps1|Everything|*.*'
    )
    
    Add-Type -AssemblyName PresentationFramework
    
    $dialog = New-Object -TypeName Microsoft.Win32.OpenFileDialog
    $dialog.Title = $Title
    $dialog.InitialDirectory = $InitialDirectory
    $dialog.Filter = $Filter
    if ($dialog.ShowDialog())
    {
        $dialog.FileName
    }
    else
    {
        Throw 'Nothing selected.'    
    }
}

Show-OpenFileDialog
