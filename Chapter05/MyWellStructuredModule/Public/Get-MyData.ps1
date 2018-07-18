function Get-MyData
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $DataKey,

        [string]
        $Filter
    )

    # Maybe call some internal validation method
    if (Test-DataKey -DataKey $DataKey)
    {
        Get-MyInternalData @PSBoundParameters
    }
}
