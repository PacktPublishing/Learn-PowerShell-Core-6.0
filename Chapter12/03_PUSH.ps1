configuration PushComesToShove
{
    node localhost
    {
        File testfile
        {
            DestinationPath = [System.IO.Path]::GetTempFileName()
            Contents = 'We love DSC'
        }
    }
}

PushComesToShove

# This cmdlet automatically targets all nodes in the sub folder
Start-DscConfiguration .\PushComesToShove -Verbose -Wait

# Is the file really created?
Test-DscConfiguration -Detailed

# We can see the current node's configuration as well
Get-DscConfiguration