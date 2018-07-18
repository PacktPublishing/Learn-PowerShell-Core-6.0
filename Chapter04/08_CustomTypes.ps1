#region Custom Types
$typeDefinition = @'
<Types>
<Type>
  <Name>System.IO.FileInfo</Name>
  <Members>
  <ScriptProperty>
    <Name>Hash</Name>
        <GetScriptBlock>Get-FileHash -Path $this.FullName</GetScriptBlock>
    </ScriptProperty>
  </Members>
</Type>
</Types>
'@

# Like Add-Member, you define which kinds of properties you want to extend your objects with
$typeDefinition | Out-File -FilePath .\MyCustomType.ps1xml

Update-TypeData -PrependPath .\MyCustomType.ps1xml

Get-Item .\MyCustomType.ps1xml | Get-Member -Name Hash
(Get-Item .\MyCustomType.ps1xml).Hash
#endregion