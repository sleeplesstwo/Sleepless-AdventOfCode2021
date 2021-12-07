$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$CrabData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")) -split ","

# Convert array to array of ints.
$CrabData = foreach ($item in $CrabData) {
    [int]::parse($item)
}

$MinPosition = ($CrabData | Measure-Object -Minimum).Minimum
$MaxPosition = ($CrabData | Measure-Object -Maximum).Maximum

$MinFuel = $null

#This is absolutely terrible but it works so enjoy while we brute force the solution.
Start-Process "https://www.youtube.com/watch?v=ZFp7VwyQLFU"


:pos for ($i = $MinPosition; $i -lt $MaxPosition; $i++) {
    $FuelUse = 0

    foreach ($item in $CrabData) {
        $PositionChange = [Math]::Abs(([int]$item - [int]$i))
        $FuelUse = $FuelUse + (@(1..$PositionChange) | Measure-Object -Sum).Sum
        if($MinFuel -lt $FuelUse -and $null -ne $MinFuel) {
            continue pos
        }
        
    }
    $MinFuel = $FuelUse
}

$MinFuel