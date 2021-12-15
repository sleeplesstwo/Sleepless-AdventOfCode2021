$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$CaveData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$CaveMap = @{}
$PathMap = @{}
$XMax = $CaveData[0].Length - 1
$YMax = $CaveData.GetUpperBound(0)
for ($y = 0; $y -le $YMax; $y++) {
    for ($x = 0; $x -le $XMax; $x++) {
        $Cavemap.Add([System.Tuple]::Create($x,$y), [int]::Parse($CaveData[$y][$x]))
        $PathMap.Add([System.Tuple]::Create($x,$y), 999999999999)
    }
}

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

$result = $PathMap[[System.Tuple]::Create($XMax,$YMax)]

$result