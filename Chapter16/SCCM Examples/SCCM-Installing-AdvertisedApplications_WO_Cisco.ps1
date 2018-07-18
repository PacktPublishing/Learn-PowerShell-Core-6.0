# Installing applications forced
$sw = Get-CimInstance -Namespace root/ccm/ClientSDK -ClassName CCM_Application | Where-Object {$_.InstallState -eq "NotInstalled" -and $_.UserUIExperience -eq "True"}
Foreach($sp in $sw){
If ([string]::IsNullOrEmpty($sp.InstallState))
{
    “software not assigned to this computer”
}
Else
{
    If ($sp.InstallState -eq “Installed”)
    {
        “Software is already installed”
    }
    Else
    {
        if($sp.Name -notlike "*Cisco*")
        {
            ([wmiclass]’ROOT\ccm\ClientSdk:CCM_Application’).Install($sp.Id, $sp.Revision, $sp.IsMachineTarget, 0, ‘Normal’, $False) | Out-Null
            “starting software installation”
        }    
    }
}

}

$UpdateList = Get-CimInstance -Namespace root/ccm/ClientSDK -ClassName CCM_SoftwareUpdate
([wmiclass]"\\$ComputerName\ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager").InstallUpdates($UpdateList) | Out-Null
