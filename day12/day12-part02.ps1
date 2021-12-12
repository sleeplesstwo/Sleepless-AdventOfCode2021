$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$CaveData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

[System.Collections.ArrayList]$Global:AllLinks = @()
foreach ($line in $CaveData) {
    $linelinks = $line -split "-"
    $LinkData = [PSCustomObject]@{
        "SideA" = $linelinks[0]
        "SideB" = $linelinks[1]
    }
    $Global:AllLinks.Add($LinkData) | Out-Null
}

[System.Collections.ArrayList]$Global:PathsTaken = @()

function Move-Room {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $CurrentPath,

        [Parameter()]
        [string[]]
        $InvalidRooms
    )
    $PotentialMoves = $Global:AllLinks | Where-Object { ($_.SideA -eq $CurrentPath[-1] -or $_.SideB -eq $CurrentPath[-1]) -and $_.SideA -notin $InvalidRooms -and $_.SideB -notin $InvalidRooms }

    $InvalidRooms = Test-ValidRoom -CurrentPath $CurrentPath

    foreach ($move in $PotentialMoves) {
        if ($move.SideA -eq $CurrentPath[-1]) {
            if ($move.SideB -eq "end") {
                $Global:PathsTaken.Add($CurrentPath + "end") | Out-Null
            }
            else {
                Move-Room -CurrentPath ($CurrentPath + $move.SideB) -InvalidRooms $InvalidRooms
            }
        }
        elseif ($move.SideB -eq $CurrentPath[-1]) {
            if ($move.SideA -eq "end") {
                $Global:PathsTaken.Add($CurrentPath + "end") | Out-Null
            }
            else {
                Move-Room -CurrentPath ($CurrentPath + $move.SideA) -InvalidRooms $InvalidRooms
            }
        }
    }
}
function Test-ValidRoom {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $CurrentPath
    )
    [System.Collections.ArrayList]$InvalidRooms = @()
    $SmallRooms = $CurrentPath | Where-Object { ($_ -cmatch "^[a-z]*$") -and $_ -ne "start"}

    $DoubledRoom = $SmallRooms | Group-Object | Where-Object {$_.Count -ge 2}
    if ($DoubledRoom.length -eq 0) {
        $InvalidRooms.Add("start") | Out-Null
    } else {
        $InvalidRooms.Add("start") | Out-Null
        foreach ($room in (($SmallRooms | Group-Object).Name)) {
            $InvalidRooms.Add($room) | Out-Null
        }
    }

    return $InvalidRooms
}

Move-Room -CurrentPath @("start")

$result = $Global:PathsTaken.Count

$result
$result | Set-Clipboard
