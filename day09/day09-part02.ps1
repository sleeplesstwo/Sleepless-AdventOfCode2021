$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$HeightData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$LineCount = $HeightData.Count
$ColCount = ($HeightData[0].toCharArray()).Count

# Build a 2 dimensional array to hold all the data.
$global:HeightMap = New-Object 'object[,]' $ColCount, $LineCount

for ($i = 0; $i -lt $LineCount; $i++) {
    $line = $HeightData[$i].toCharArray()
    for ($j = 0; $j -lt $ColCount; $j++) {
        $global:HeightMap[$j, $i] = [int]::Parse($line[$j])
    }
}

[System.Collections.ArrayList]$lowPoints = @()
for ($i = 0; $i -lt $LineCount; $i++) {
    $line = $HeightData[$i].toCharArray()
    for ($j = 0; $j -lt $ColCount; $j++) {
        $height = $global:HeightMap[$j, $i]
        $AdjacentValues = @()
        if ($i -gt 0) {
            $AdjacentValues += $global:HeightMap[$j, ($i - 1)]
        }
        if ($j -gt 0) {
            $AdjacentValues += $global:HeightMap[($j - 1), $i]
        }
        if ($i -lt $LineCount - 1) {
            $AdjacentValues += $global:HeightMap[$j, ($i + 1)]
        }
        if ($j -lt $ColCount - 1) {
            $AdjacentValues += $global:HeightMap[($j + 1), $i]
        }
        $lowest = $true
        foreach ($value in $AdjacentValues) {
            if ($global:HeightMap[$j, $i] -ge $value) {
                $lowest = $false
            }
        }
        if ($lowest) {
            $location = [PSCustomObject]@{
                'x' = $j
                'y' = $i
            }
            $lowPoints.Add($location) | Out-Null
            
        }
    }
}

function Test-Basin {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $x,

        [Parameter()]
        [int]
        $y

    )

    $global:BasinLocations += "$x,$y"
    $height = [int]::Parse(($global:HeightMap[$x,$y]))
    if ($x -ne 0) {
        $adjacentHeight = [int]::Parse(($global:HeightMap[($x-1),$y]))
        if ($adjacentHeight -gt $height -and $adjacentHeight -ne 9) {
            Test-Basin -x ($x-1) -y $y
        }
    }
    if ($y -ne 0) {
        $adjacentHeight = [int]::Parse(($global:HeightMap[$x,($y-1)]))
        if ($adjacentHeight -gt $height -and $adjacentHeight -ne 9) {
            Test-Basin -x $x -y ($y-1)
        }
    }
    if ($x -lt $global:HeightMap.GetUpperBound(0)) {
        $adjacentHeight = [int]::Parse(($global:HeightMap[($x+1),$y]))
        if ($adjacentHeight -gt $height -and $adjacentHeight -ne 9) {
            Test-Basin -x ($x+1) -y $y
        }
    }
    if ($y -lt $global:HeightMap.GetUpperBound(1)) {
        $adjacentHeight = [int]::Parse(($global:HeightMap[$x,($y+1)]))
        if ($adjacentHeight -gt $height -and $adjacentHeight -ne 9) {
            Test-Basin -x $x -y ($y+1)
        }
    }

}

[System.Collections.ArrayList]$BasinSizes = @()
$totalToCheck = $lowPoints.count
$currentProgress = 1
foreach ($point in $lowPoints) { 
    Write-Progress -Activity "Checking Points" -PercentComplete (($currentProgress / $totalToCheck)*100) -Status "Checking $currentProgress of $totalToCheck"
    $global:BasinLocations = @()
    Test-Basin -x $point.x -y $point.y
    $BasinSizes.Add((($global:BasinLocations | Group-Object).Count)) | Out-Null
    $currentProgress++
}
    Write-Progress -Activity "Checking Points" -Completed
$BasinSizes = $BasinSizes | Sort-Object -Descending | Select-Object -First 3

$results = $BasinSizes[0] * $BasinSizes[1] * $BasinSizes[2]

$results
$results | Set-Clipboard