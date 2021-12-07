function Get-Median {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int[]]
        $InputObject
    )

        $InputObject = $InputObject | Sort-Object
        if ($InputObject.count % 2) {
            # Odd number of elements
            $median = $InputObject[[math]::Floor($data.count/2)]
        }
        else {
            $median = ($InputObject[$InputObject.Count/2],$InputObject[$InputObject.Count/2-1] | Measure-Object -Average).Average
        }
        return $median
}

$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$CrabData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")) -split ","

# Convert array to array of ints.
$CrabData = foreach ($item in $CrabData) {
    [int]::parse($item)
}

$MedianPosition = Get-Median -InputObject $CrabData
$FuelUse = 0

foreach ($item in $CrabData) {
    $FuelUse = $FuelUse + [Math]::Abs(([int]$item - [int]$MedianPosition))
}

$FuelUse