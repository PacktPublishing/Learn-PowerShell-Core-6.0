#region Working with format data

# Retrieve existing data to modify it
$existingFormat = Get-FormatData -TypeName Microsoft.PowerShell.Commands.FileHashInfo
$existingFormat | Export-FormatData -Path .\Microsoft.PowerShell.Commands.FileHashInfo.format.ps1xml -IncludeScriptBlock

# Notice the existing format. The Algorithm comes first
Get-FileHash .\Microsoft.PowerShell.Commands.FileHashInfo.format.ps1xml

# Change the XML to display the path first, then the hash, then the algorithm
psedit .\Microsoft.PowerShell.Commands.FileHashInfo.format.ps1xml

# Update data after modifications
# Prepending allows us to override the existing data
# Appending is more suited to new object types not already formatted
Update-FormatData -PrependPath .\Microsoft.PowerShell.Commands.FileHashInfo.format.ps1xml

# Notice the changed format
Get-FileHash .\Microsoft.PowerShell.Commands.FileHashInfo.format.ps1xml

# What a custom format could look like
$formatXml = @"
<Configuration>
<ViewDefinitions>
  <View>
    <Name>System.Diagnostics.Process</Name>
    <ViewSelectedBy>
      <TypeName>System.Diagnostics.Process</TypeName>
    </ViewSelectedBy>
    <TableControl>
        <AutoSize />
        <TableHeaders>
          <TableColumnHeader>
            <Label>Name</Label>
          </TableColumnHeader>
          <TableColumnHeader>
            <Label>WS in MB</Label>
          </TableColumnHeader>
        </TableHeaders>
      <TableRowEntries>
        <TableRowEntry>
          <TableColumnItems>
            <TableColumnItem>
              <PropertyName>ProcessName</PropertyName>
            </TableColumnItem>
            <TableColumnItem>
              <ScriptBlock>[Math]::Round(($_.WorkingSet64 / 1MB),2)</ScriptBlock>              
            </TableColumnItem>
            </TableColumnItems>
          </TableRowEntry>
        </TableRowEntries>
      </TableControl>
    </View>
</ViewDefinitions>
</Configuration>
"@

$formatXml | Out-File .\MyCustomFormat.ps1xml
Update-FormatData -PrependPath .\MyCustomFormat.ps1xml
Get-Process -Id $Pid
#endregion