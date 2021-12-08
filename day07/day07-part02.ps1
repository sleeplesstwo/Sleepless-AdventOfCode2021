$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$CrabData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")) -split ","

# Convert array to array of ints.
$CrabData = foreach ($item in $CrabData) {
    [int]::parse($item)
}

# Get the minimum and maximum position values, no sense checking outside those.
$MinPosition = ($CrabData | Measure-Object -Minimum).Minimum
$MaxPosition = ($CrabData | Measure-Object -Maximum).Maximum

$MinFuel = $null

#This is absolutely terrible but it works so enjoy while we brute force the solution.
Start-Process "https://www.youtube.com/watch?v=ZFp7VwyQLFU"

:pos for ($i = $MinPosition; $i -lt $MaxPosition; $i++) {
    $FuelUse = 0

    foreach ($item in $CrabData) {
        # How many positions did we change?
        $PositionChange = [Math]::Abs(([int]$item - [int]$i))
        # Measure sum of values in array containing every int from 1 to the number of positions we changed
        $FuelUse = $FuelUse + (@(1..$PositionChange) | Measure-Object -Sum).Sum

        # No point in continuing if we've already exceeded the prior minimum. Exempt the initial pass by checking for null.
        if($MinFuel -lt $FuelUse -and $null -ne $MinFuel) {
            continue pos
        }
        
    }
    # If we've made it out of the inner loop then a new minimum was found
    $MinFuel = $FuelUse
}

$MinFuel
$MinFuel | Set-Clipboard