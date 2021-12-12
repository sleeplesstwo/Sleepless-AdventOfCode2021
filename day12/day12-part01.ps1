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

    $InvalidRooms = $CurrentPath | Where-Object { ($_ -cmatch "^[a-z]*$")}
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

Move-Room -CurrentPath @("start")

$result = $Global:PathsTaken.Count

$result
$result | Set-Clipboard