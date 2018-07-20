function Write-CMLogEntry
{
    <#
    .Synopsis
       Logs the entry in an CMTrace-compatible format to an logpath.
    .EXAMPLE
       Write-CMLogEntry -Value 'Example' -Severity 2 -LogFilePath $LogFilePath 
    .EXAMPLE
        $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
        $LogFilePath = Join-Path -Path $Script:TSEnvironment.Value('_SMSTSLogPath') -ChildPath $FileName
        Write-CMLogEntry -Value 'ExampleWithLogFilePath' -Severity 1 -LogFilePath $LogFilePath 
    .EXAMPLE
    Begin {
            # Construct TSEnvironment object
            try 
            {
                $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
            }
            catch
            {
                Write-Warning -Message 'Unable to construct Microsoft.SMS.TSEnvironment object' 
                exit 1
            }
            $Filename = 'LogFile.log'

            # Determine log file location
            $LogFilePath = Join-Path -Path $Script:TSEnvironment.Value('_SMSTSLogPath') -ChildPath $FileName
        }
    Process {
            Write-CMLogEntry -Value 'ExampleWithLogFilePath' -Severity 3 -LogFilePath $LogFilePath 
        }



        The above code can be used in scripts to be executed with SCCM, which is why exit is used instead of returning or throwing.
        It will write a message "ExampleWithLogFilePath" with severity 3 to a specified log file.
    #>
    param(
        [parameter(Mandatory = $true, HelpMessage = 'Value added to the logfile.')]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory = $true, HelpMessage = 'Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('1', '2', '3')]
        [string]$Severity,

        [parameter(Mandatory = $true, HelpMessage = 'Name of the log file that the entry will written to.')]
        [ValidateNotNullOrEmpty()]
        [string]$LogFilePath
    )
    Process {
        # Construct time stamp for log entry
        $Time = -join @((Get-Date -Format 'HH:mm:ss.fff'), '+', (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))

        # Construct date for log entry
        $Date = (Get-Date -Format 'MM-dd-yyyy')

        # Construct context for log entry
        $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)

        # Construct final log entry
        $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""DynamicApplicationsList"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"
	
        # Add value to log file
        try 
        {
            Add-Content -Value $LogText -LiteralPath $LogFilePath -ErrorAction Stop
        }
        catch
        {
            Write-Warning -Message "Unable to append log entry to logfile: $LogFilePath"
        }
    }
}
