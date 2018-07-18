<#     
    .NOTES
    ===========================================================================
    Created on:     09.01.2017
    Created by:     David das Neves, PFE       
    Organization:   Microsoft Germany GmbH
    Filename:       New-CleanupDisk.ps1
    ===========================================================================
    .DESCRIPTION
    Runs cleanmgr

    .DISCLAIMER
    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER 
    EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
    OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

    This sample is not supported under any Microsoft standard support program 
    or service. The script is provided AS IS without warranty of any kind. 
    Microsoft further disclaims all implied warranties including, without 
    limitation, any implied warranties of merchantability or of fitness for a 
    particular purpose. The entire risk arising out of the use or performance
    of the sample and documentation remains with you. In no event shall 
    Microsoft, its authors, or anyone else involved in the creation, 
    production, or delivery of the script be liable for any damages whatsoever 
    (including, without limitation, damages for loss of business profits, 
    business interruption, loss of business information, or other pecuniary 
    loss) arising out of the use of or inability to use the sample or 
    documentation, even if Microsoft has been advised of the possibility of 
    such damages.
#>
function New-CleanupDisk
{
  Param
  (
    [Parameter(ValueFromPipeline = $true)]  
    [Switch]$CleanPreviousInstallations 
  )
  
  function Match-ArrayItem 
  {
    param (
      [array]$Arr,
      [string]$Item
    )

    $result = ($null -ne ($Arr | Where-Object -FilterScript {
          $Item -match $_
    }))
    return $result
  }

  $Excludes = @('Previous Installations')


  Set-Location -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\'

  foreach ($Item in $(Get-ChildItem).PSPath)
  {
    if ((-not (Get-ItemProperty -Path $Item -Name 'StateFlags1234' -ErrorAction SilentlyContinue)) -and (-not(Match-ArrayItem -Arr $Excludes -Item $Item)))
    {
      $null = New-ItemProperty -Path $Item -Name 'StateFlags1234' -Value 2 -ErrorAction SilentlyContinue
    }
    Elseif ((Get-ItemProperty -Path $Item -Name 'StateFlags1234' -ErrorAction SilentlyContinue) -and (Match-ArrayItem -Arr $Excludes -Item $Item))
    {
      $null = Remove-ItemProperty -Path $Item -Name 'StateFlags1234' -Force
    }
  }

  if ($CleanPreviousInstallations -and (((Get-WmiObject -Class win32_operatingsystem).version)[0] -eq '10'))
  {
    cleanmgr.exe /AutoClean
  }

  cleanmgr.exe /sagerun:1234 
}
New-CleanupDisk