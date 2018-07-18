using namespace Microsoft.PowerShell.SHiPS

class Cloud : SHiPSDirectory
{
    Cloud(
        [string]$name) : base($name)
    {
    }

    [object[]] GetChildItem()
    {
        # Return some unique tenant ids
        return ([Tenant]::new('localhost'))
    }
}

class Tenant : SHiPSDirectory
{
    Tenant(
        [string]$name) : base($name)
    {
    }

    [object[]] GetChildItem()
    {
        $obj = @()      
        $obj += [Machine]::new('Machines')
        $obj += [Disk]::new('Disks')
        $obj += [VirtualSwitch]::new('Switches')
        return $obj;
    }
}

class VirtualSwitch : SHiPSDirectory
{
    VirtualSwitch(
        [string]$name) : base($name)
    {
    }

    [object[]] GetChildItem()
    {
        return (Get-VMSwitch)
    }
}

class Disk : SHiPSDirectory
{
    Disk(
        [string]$name) : base($name)
    {
    }

    [object[]] GetChildItem()
    {
        return (Get-VM | Get-VMHardDiskDrive | Select -Expand Path)
    }
}

class Machine : SHiPSDirectory
{
    Machine(
        [string]$name) : base($name)
    {
    }

    [object[]] GetChildItem()
    {
        return (Get-VM)
    }
}