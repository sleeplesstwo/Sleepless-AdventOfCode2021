$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$HeightData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$LineCount = $HeightData.Count
$ColCount = ($HeightData[0].toCharArray()).Count

# Build a 2 dimensional array to hold all the data.
$HeightMap = New-Object 'object[,]' $ColCount,$LineCount

for ($i=0; $i -lt $LineCount; $i++) {
    $line = $HeightData[$i].toCharArray()
    for ($j=0; $j -lt $ColCount; $j++) {
        $HeightMap[$j,$i] = [int]::Parse($line[$j])
    }
}
[System.Collections.ArrayList]$lowPoints = @()
for ($i=0; $i -lt $LineCount; $i++) {
    $line = $HeightData[$i].toCharArray()
    for ($j=0; $j -lt $ColCount; $j++) {
        $height = $HeightMap[$j,$i]
        $AdjacentValues = @()
        if ($i -gt 0) {
            $AdjacentValues += $HeightMap[$j,($i-1)]
        }
        if ($j -gt 0) {
            $AdjacentValues += $HeightMap[($j-1),$i]
        }
        if ($i -lt $LineCount-1) {
            $AdjacentValues += $HeightMap[$j,($i+1)]
        }
        if ($j -lt $ColCount-1) {
            $AdjacentValues += $HeightMap[($j+1),$i]
        }
        $lowest = $true
        foreach($value in $AdjacentValues) {
            if ($HeightMap[$j,$i] -ge $value) {
                $lowest = $false
            }
        }
        if ($lowest) {
            $lowPoints.Add(($HeightMap[$j,$i])) | Out-Null
        }
    }
}

$riskLevel = 0
foreach ($value in $lowPoints) {
    $riskLevel = $riskLevel + ($value + 1)
}

$riskLevel
$riskLevel | Set-Clipboard