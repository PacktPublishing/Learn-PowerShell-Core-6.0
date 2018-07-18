<#
    .Synopsis
    Convert PowerPoint files to pdf.
    .DESCRIPTION
    Convert PowerPoint files to pdf. Searches recursively in complete folders.
    .EXAMPLE
    Convert-PPTXtoPDF -Path c:\Workshops\
#> 
function Convert-PPTXtoPDF
{ 
  [CmdletBinding()]
  Param
  (
    # Folder or File
    [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
    Position = 0)]
    $Path  
  )
  #Load assembly.
  $null = Add-Type -AssemblyName Microsoft.Office.Interop.PowerPoint
  
  #Store SaveOption
  $SaveOption = [Microsoft.Office.Interop.PowerPoint.PpSaveAsFileType]::ppSaveAsPDF
      
  #Open PowerPoint ComObject
  $PowerPoint = New-Object -ComObject 'PowerPoint.Application'
  
  #Retrieve all pptx elements recursively.
  Get-ChildItem $Path -File -Filter *pptx -Recurse |
  ForEach-Object -Begin {
  } -Process {
    #create a pdf file for each found pptx file
    $Presentation = $PowerPoint.Presentations.Open($_.FullName)
    $PdfNewName  = $_.FullName -replace '\.pptx$', '.pdf'
    $Presentation.SaveAs($PdfNewName,$SaveOption)
    $Presentation.Close()
  } -End {
    #Close Powerpoint after the last conversion 
    $PowerPoint.Quit()
    
    #Kill process
    Stop-Process -Name POWERPNT -Force
  }
}
