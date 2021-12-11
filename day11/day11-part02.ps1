$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$OctopusData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$LineCount = $OctopusData.Count
$ColCount = ($OctopusData[0].toCharArray()).Count

$Global:energyMap = New-Object 'object[,]' $ColCount,$LineCount

# Populate the multidimentional array

for ($i=0; $i -lt $LineCount; $i++) {
    $line = $OctopusData[$i].toCharArray()
    for ($j=0; $j -lt $ColCount; $j++) {
        $Global:energyMap[$j,$i] = [int]::Parse($line[$j])
    }
}

$FlashCount = 0

function Get-EnergyMap {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Pass
    )
    Write-Host "Pass: $Pass"
    for ($y=0; $y -le ($Global:energyMap.GetUpperBound(1)); $y++) {
        $outputString = ""
        for ($x=0; $x -le ($Global:energyMap.GetUpperBound(0)); $x++) {
            $outputString += $Global:energyMap[$x,$y]
            $outputString += "|"
        }
        Write-Host "$outputString"
    }
}

function Process-Flashpoint {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $x,

        [Parameter()]
        [int]
        $y
    )

    $LineCount = $Global:energyMap.GetUpperBound(1)
    $ColCount = $Global:energyMap.GetUpperBound(0)

    if ($x -ne 0 -and $y -ne 0) {
        $Global:energyMap[($x-1),($y-1)]++
        if ($Global:energyMap[($x-1),($y-1)] -gt 9 -and ($Global:SecondaryPoints | Where-Object {$_.x -eq ($x-1) -and $_.y -eq ($y-1)}).Count -eq 0) {
            $Global:SecondaryPoints.Add([PSCustomObject]@{
                'x' = ($x-1)
                'y' = ($y-1)
            }) | Out-Null
            Process-Flashpoint -x ($x-1) -y ($y-1)
        }
    }
    if ($y -ne 0) {
        $Global:energyMap[$x,($y-1)]++
        if ($Global:energyMap[$x,($y-1)] -gt 9 -and ($Global:SecondaryPoints | Where-Object {$_.x -eq $x -and $_.y -eq ($y-1)}).Count -eq 0) {
            $Global:SecondaryPoints.Add([PSCustomObject]@{
                'x' = $x
                'y' = ($y-1)
            }) | Out-Null
            Process-Flashpoint -x ($x) -y ($y-1)
        }
    }
    if ($y -ne 0 -and $x -le $ColCount-1) {
        $Global:energyMap[($x+1),($y-1)]++
        if ($Global:energyMap[($x+1),($y-1)] -gt 9 -and ($Global:SecondaryPoints | Where-Object {$_.x -eq ($x+1) -and $_.y -eq ($y-1)}).Count -eq 0) {
            $Global:SecondaryPoints.Add([PSCustomObject]@{
                'x' = $x+1
                'y' = $y-1
            }) | Out-Null
            Process-Flashpoint -x ($x+1) -y ($y-1)
        }
    }
    if ($x -ne 0) {
        $Global:energyMap[($x-1),$y]++
        if ($Global:energyMap[($x-1),$y] -gt 9 -and ($Global:SecondaryPoints | Where-Object {$_.x -eq ($x-1) -and $_.y -eq $y}).Count -eq 0) {
            $Global:SecondaryPoints.Add([PSCustomObject]@{
                'x' = $x-1
                'y' = $y
            }) | Out-Null
            Process-Flashpoint -x ($x-1) -y ($y)
        }
    }
    if ($x -le $ColCount-1) {
        $Global:energyMap[($x+1),$y]++
        if ($Global:energyMap[($x+1),$y] -gt 9 -and ($Global:SecondaryPoints | Where-Object {$_.x -eq ($x+1) -and $_.y -eq $y}).Count -eq 0) {
            $Global:SecondaryPoints.Add([PSCustomObject]@{
                'x' = $x+1
                'y' = $y
            }) | Out-Null
            Process-Flashpoint -x ($x+1) -y ($y)
        }
    }
    if ($x -ne 0 -and $y -le $LineCount-1) {
        $Global:energyMap[($x-1),($y+1)]++
        if ($Global:energyMap[($x-1),($y+1)] -gt 9 -and ($Global:SecondaryPoints | Where-Object {$_.x -eq ($x-1) -and $_.y -eq ($y+1)}).Count -eq 0) {
            $Global:SecondaryPoints.Add([PSCustomObject]@{
                'x' = $x-1
                'y' = $y+1
            }) | Out-Null
            Process-Flashpoint -x ($x-1) -y ($y+1)
        }
    }
    if ($y -le $LineCount-1) {
        $Global:energyMap[$x,($y+1)]++
        if ($Global:energyMap[$x,($y+1)] -gt 9 -and ($Global:SecondaryPoints | Where-Object {$_.x -eq $x -and $_.y -eq ($y+1)}).Count -eq 0) {
            $Global:SecondaryPoints.Add([PSCustomObject]@{
                'x' = $x
                'y' = $y+1
            }) | Out-Null
            Process-Flashpoint -x ($x) -y ($y+1)

        }
    }
    if ($x -le $ColCount-1 -and $y -le $LineCount-1) {
        $Global:energyMap[($x+1),($y+1)]++
        if ($Global:energyMap[($x+1),($y+1)] -gt 9 -and ($Global:SecondaryPoints | Where-Object {$_.x -eq ($x+1) -and $_.y -eq ($y+1)}).Count -eq 0) {
            $Global:SecondaryPoints.Add([PSCustomObject]@{
                'x' = $x+1
                'y' = $y+1
            }) | Out-Null
            Process-Flashpoint -x ($x+1) -y ($y+1)
        }
    }
}

# Process each turn
$AllFlashed = $false
$Step = 0
while ($AllFlashed -eq $false) {
    $Step++
    Write-Host "Step: $Step"
    # First we increase all values in the 2D array by 1.

    for ($i = 0; $i -lt $LineCount; $i++) {
        for ($j = 0; $j -lt $ColCount; $j++) {
            $Global:energyMap[$j, $i]++
        }
    }
    [System.Collections.ArrayList]$Global:FlashPoints = @()
    :isNine for ($i = 0; $i -lt $LineCount; $i++) {
        
        #First find all the locations that will flash.
        for ($j = 0; $j -lt $ColCount; $j++) {
            if ($Global:energyMap[$j, $i] -gt 9) {
                #Write-Host "Point $j,$i is value $($Global:energyMap[$j,$i])"
                $FlashPoint = [PSCustomObject]@{
                    'x' = $j
                    'y' = $i
                }
                $Global:FlashPoints.Add($FlashPoint) | Out-Null
            }
        }
    }
    # Process the secondary points off the initial flashes
    [System.Collections.ArrayList]$Global:SecondaryPoints = @()
    $Global:SecondaryPoints = $Global:SecondaryPoints + $Global:FlashPoints
    if ($Global:FlashPoints.Count -ne 0) {
        foreach ($location in $Global:FlashPoints) {
            Process-Flashpoint -x $location.x -y $location.y
        }

        $AllFlashed = $true
        for ($i = 0; $i -lt $LineCount; $i++) {
            for ($j = 0; $j -lt $ColCount; $j++) {
                if ($Global:energyMap[$j, $i] -gt 9) {
                    $Global:energyMap[$j, $i] = 0
                    $FlashCount++
                }
                else {
                    $AllFlashed = $false
                }
            }
        }
    }
}

$Step

$Step | Set-Clipboard