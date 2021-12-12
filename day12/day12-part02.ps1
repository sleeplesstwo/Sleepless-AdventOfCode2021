$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$CaveData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

# Load the cave connections into an object to track the links.
[System.Collections.ArrayList]$Global:AllLinks = @()
foreach ($line in $CaveData) {
    $linelinks = $line -split "-"
    $LinkData = [PSCustomObject]@{
        "SideA" = $linelinks[0]
        "SideB" = $linelinks[1]
    }
    $Global:AllLinks.Add($LinkData) | Out-Null
}

# Start with an empty arraylist of paths taken to reach the end.
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

    # Get a list of the links where either A or B side is equal to the last item in the current path (current room) and is not listed in invalid rooms
    $PotentialMoves = $Global:AllLinks | Where-Object { ($_.SideA -eq $CurrentPath[-1] -or $_.SideB -eq $CurrentPath[-1]) -and $_.SideA -notin $InvalidRooms -and $_.SideB -notin $InvalidRooms }

    # Update the invalid rooms with the current path
    $InvalidRooms = Test-ValidRoom -CurrentPath $CurrentPath

    foreach ($move in $PotentialMoves) {
        # If the current room is on SideA we move to SideB
        if ($move.SideA -eq $CurrentPath[-1]) {
            if ($move.SideB -eq "end") {
                # If the move it to end then we've completed a path, add the path to our arraylist of paths taken
                $Global:PathsTaken.Add($CurrentPath + "end") | Out-Null
            }
            else {
                # Otherwise move to the new room by recursively calling the function
                Move-Room -CurrentPath ($CurrentPath + $move.SideB) -InvalidRooms $InvalidRooms
            }
        }
        # Otherwise if we're on SideB of the link we move to SideA
        elseif ($move.SideB -eq $CurrentPath[-1]) {
            if ($move.SideA -eq "end") {
                # If the move it to end then we've completed a path, add the path to our arraylist of paths taken
                $Global:PathsTaken.Add($CurrentPath + "end") | Out-Null
            }
            else {
                # Otherwise move to the new room by recursively calling the function
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
    # Find all the small rooms in our current path
    $SmallRooms = $CurrentPath | Where-Object { ($_ -cmatch "^[a-z]*$") -and $_ -ne "start"}

    # Have we been in any small rooms twice?  If not then all small rooms are still valid
    $DoubledRoom = $SmallRooms | Group-Object | Where-Object {$_.Count -ge 2}
    if ($DoubledRoom.length -eq 0) {
        $InvalidRooms.Add("start") | Out-Null
    } else {
        # Otherwise all small rooms are now invalid
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
