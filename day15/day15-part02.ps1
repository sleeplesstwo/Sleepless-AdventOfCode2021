$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$CaveData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$CaveMap = @{}
$PathMap = @{}
$XMax = $CaveData[0].Length - 1
$YMax = $CaveData.GetUpperBound(0)
for ($i=0; $i -lt 5; $i++){
    for ($y = 0; $y -le $YMax; $y++) {
        for ($j=0; $j -lt 5; $j++) {
            for ($x = 0; $x -le $XMax; $x++) {
                $RiskValue = [int]::Parse($CaveData[$y][$x]) + (1*$j) + (1*$i)
                if ($RiskValue -gt 9) {
                    $RiskValue = $RiskValue - 9
                }
                $BigX = (($XMax + 1) * $j) + $x
                $BigY = (($YMax + 1) * $i) + $y
                $Cavemap.Add([System.Tuple]::Create($BigX,$BigY), $RiskValue)
                $PathMap.Add([System.Tuple]::Create($BigX,$BigY), 999999999999)
            }
        }
        
    }
}

[int]$XMax = ($CaveMap.Keys.Item1 | Measure-Object -Maximum).Maximum
[int]$YMax = ($CaveMap.Keys.Item2 | Measure-Object -Maximum).Maximum


$PathMap[[System.Tuple]::Create(0,0)] = 0
$EndPoint = [System.Tuple]::Create($XMax,$YMax)
[System.Collections.ArrayList]$Global:VisitedNodes = @()

$Queue = [System.Collections.Generic.PriorityQueue[PSCustomObject, int]]::new()
$Queue.Enqueue([System.Tuple]::Create(0,0), 0)
$CurrentRisk = 0

function Get-UnvisitedNeighbors {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Tuple[int,int]]
        $point,

        [Parameter()]
        [int]
        $XMax,

        [Parameter()]
        [int]
        $YMax
    )

    $deltas = @(
        ,@(-1,0)
        ,@(1,0)
        ,@(0,-1)
        ,@(0,1)
    )

    $NeighborList = foreach ($d in $deltas) {
        $dx = $point.Item1 + $d[0]
        $dy = $point.Item2 + $d[1]
        if ($dx -lt 0 -or $dx -gt $XMax) { continue }
        if ($dy -lt 0 -or $dy -gt $YMax) { continue }
        [System.Tuple]::Create($dx, $dy)
    }
    return $NeighborList
}

while ($Queue.Count -ne 0) {
    $CurrentPoint = $Queue.Dequeue()
    $NeighborList = Get-UnvisitedNeighbors -XMax $XMax -YMax $YMax -point $CurrentPoint
    foreach ($Neighbor in $NeighborList) {
        $TotalRisk = $CaveMap[$Neighbor] + $PathMap[$CurrentPoint]
        if ($TotalRisk -lt $PathMap[$Neighbor]) {
            $PathMap[$Neighbor] = $TotalRisk
            $Queue.Enqueue($Neighbor, $TotalRisk)
        }
        if($Neighbor -eq $EndPoint) {
            $Queue.Clear()
        }
    }
}

$result = $PathMap[$EndPoint]

$result