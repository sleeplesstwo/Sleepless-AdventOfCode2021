$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$HeightData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$LineCount = $HeightData.Count
$ColCount = ($HeightData[0].toCharArray()).Count

# Build a 2 dimensional array as a global variable to hold all the data
# This saves on RAM and execution since we don't have to copy it through every pass of the checking function later
$global:HeightMap = New-Object 'object[,]' $ColCount, $LineCount

#Populate the array with values
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

    # Add the X,Y value to the global BasinLocations variable
    $global:BasinLocations += "$x,$y"
    $height = [int]::Parse(($global:HeightMap[$x,$y]))

    # Check each adjacent square to see if it's larger so long as we aren't on an edge
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

# Setup values for progress bar
$totalToCheck = $lowPoints.count
$currentProgress = 1

foreach ($point in $lowPoints) { 
    Write-Progress -Activity "Checking Points" -PercentComplete (($currentProgress / $totalToCheck)*100) -Status "Checking $currentProgress of $totalToCheck"
    # Clear the global BasinLocations value on each pass
    $global:BasinLocations = @()
    Test-Basin -x $point.x -y $point.y

    # Group up the values in BasinLocations to get a list of unique x,y coordinates that are part of the basin and get a count of them to add to the array of BasinSizes
    $BasinSizes.Add((($global:BasinLocations | Group-Object).Count)) | Out-Null
    $currentProgress++
}
    # Set the progress bar to Complete 
    Write-Progress -Activity "Checking Points" -Completed

#Sort the array of BasinSizes largest to smallest and take the first 3
$BasinSizes = $BasinSizes | Sort-Object -Descending | Select-Object -First 3

$results = $BasinSizes[0] * $BasinSizes[1] * $BasinSizes[2]

$results
$results | Set-Clipboard