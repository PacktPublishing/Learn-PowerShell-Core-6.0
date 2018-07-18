# Leveraging external commands

# Sample 1 - Creating users on Windows and Linux hosts
$windowsMachines = 'WindowsHost1', 'WindowsHost2'
$linuxMachines = 'LinuxHost1', 'LinuxHost2'

$username = 'localuser1'
$password = 'P@ssw0rd' | ConvertTo-SecureString -AsPlainText -Force
$newCredential = New-Object -TypeName pscredential $userName, $password

$linuxSessionOptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$sessions = @(New-PSSession $windowsMachines -Credential (Get-Credential))
$sessions += New-PSSession $linuxMachines -UseSSL -SessionOption $linuxSessionOptions -Authentication Basic -Credential (Get-Credential)

Invoke-Command -Session $sessions -ScriptBlock {
    param
    (
        $Credential
    )
    if ($PSVersionTable.PSEdition -eq 'Desktop' -and $PSVersionTable.PSVersion -ge 5.1)
    {
        New-LocalUser -Name $Credential.UserName -Password $Credential.Password -ErrorAction Stop
    }
    elseif ($PSVersionTable.PSEdition -eq 'Core' -and $IsLinux)
    {
        $userCreation = Start-Process -FilePath '/sbin/useradd' -ArgumentList $Credential.UserName -Wait -NoNewWindow -PassThru

        if ($userCreation.ExitCode -ne 0)
        {
            Write-Error -Message "Failed to create $($Credential.UserName)"
            return
        }

        $Credential.GetNetworkCredential().Password | passwd --stdin $Credential.UserName
    }
} -ArgumentList $newCredential

# Sample 2 - External commands with Start-Process
$executable = 'msiexec' # Executable in PATH
$arguments = @( # An array of commandline arguments
    '/i "C:\Temp\myMsiFile.msi"'
    '/l*v "D:\Some log folder\myMsiFile.log'
    '/quiet'
    '/norestart'
)

# Fork a new process, wait for it to finish while not creating a new window
# We use PassThru to capture the result of our action
$installation = Start-Process -FilePath $executable -ArgumentList $arguments -Wait -NoNewWindow -PassThru

if ($installation.ExitCode -notin 0, 3010)
{
    Write-Error -Message "The installation failed with exit code $($installation.ExitCode)"
}

# Sample 3 - External commands inline
$logPath = [System.Io.Path]::GetTempFileName()
robocopy C:\Temp C:\Tmp /S /E /LOG:$logPath # Variables may appear inline

# Sample 4 - Redirecting output to external commands
$diskpartCmd = 'LIST DISK'
$disks = $diskpartCmd | diskpart.exe

# Sample 4 - Redirection and external commands

# Redirect STDERR to err.txt and STDOUT to out.txt
Get-Item $PSHome, C:\DoesNotExist 2>err.txt 1>out.txt
Get-Content out.txt # Displays the one folder $PSHome that was accessible
Get-Content err.txt # Displays the error record that was captured

# Some commands fill the wrong streams
$outputWillBeEmpty = git clone https://github.com/AutomatedLab/AutomatedLab.Common 2>NotAnError.txt # Success output lands in the error stream
$outputWillBeEmpty -eq $null
$outputIsFine = git clone https://github.com/AutomatedLab/AutomatedLab.Common 2>&1 # Instead of redirecting the error to a file, combine it into the output stream
$outputIsFine

# Creating a .NET process object to capture stdout and stderr properly
$process = New-Object -TypeName System.Diagnostics.Process

# The ProcessStartInfo is the relevant part here
$startInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
$startInfo.RedirectStandardError = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.UseShellExecute = $false # This is a requirement to redirect the streams.
$startInfo.FileName = 'git.exe'
$path = [System.IO.Path]::GetTempFileName() -replace '\.tmp'
$startInfo.Arguments = 'clone "https://github.com/AutomatedLab/AutomatedLab.Common" {0}' -f $path

$process.StartInfo = $startInfo
$process.Start()

# Read all output BEFORE waiting for the process to exit
# otherwise you might provoke a hang
$errorOutput = $process.StandardError.ReadToEnd()
$standardOutput = $process.StandardOutput.ReadToEnd()

$process.WaitForExit()

if ($process.ExitCode -ne 0)
{
    Write-Error -Message $errorOutput
    return
}

# In case of git, the developers decided to return success output on the error stream
Write-Verbose -Message $errorOutput
# In most cases, the standard output should be fine however
Write-Verbose -Message $standardOutput