<#
.SYNOPSIS
  Retrieves folder size.
.DESCRIPTION
  Retrieves folder size of a dedicated path or all subfolders of the dedicated path.
.EXAMPLE
  Get-FolderSize -Path c:\temp\ -ShowSubFolders | Format-List
.INPUTS
  Path
.OUTPUTS
  Path and Sizes
.NOTES
  folder size example
#>
function Get-FolderSize {
  Param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    $Path,
    [ValidateSet("KB","MB","GB")]
    $Units = "MB",
    [Switch] $ShowSubFolders = $false
  )
  if((Test-Path $Path) -and (Get-Item $Path).PSIsContainer ) 
  {
    if ($ShowSubFolders) 
    {
      $subFolders = Get-ChildItem $Path -Directory 
      foreach ($subFolder in $subFolders) 
      {
        $Measure = Get-ChildItem $subFolder.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        $Sum = $Measure.Sum / "1$Units"
        [PSCustomObject]@{
          "Path" = $subFolder
          "Size($Units)" = [Math]::Round($Sum,2)
        }
      }
    }
    else 
    {
      $Measure = Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
      $Sum = $Measure.Sum / "1$Units"
      [PSCustomObject]@{
        "Path" = $Path
        "Size($Units)" = [Math]::Round($Sum,2)
      }
    }
  }
}

Get-FolderSize -Path c:\temp\ -ShowSubFolders | Format-List

