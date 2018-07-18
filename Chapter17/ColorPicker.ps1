function New-ColorPickerDialog {
    $colorDialog = New-Object System.Windows.Forms.ColorDialog 
    $colorDialog.AllowFullOpen = $false
    [void]$colorDialog.ShowDialog()
    $colorDialog.Color.Name
}

New-ColorPickerDialog

