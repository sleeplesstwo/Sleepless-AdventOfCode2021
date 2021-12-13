# Both parts in one file, see comments at end on where to change to get part 1 vs part 2 answer

$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$PaperData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

# Initialize arraylist for dots and folds
[System.Collections.ArrayList]$DotArray = @()
[System.Collections.ArrayList]$FoldList = @()

# Parse input file, start with the dots.
$FoldInput = $false
foreach ($point in $PaperData) {
    if ($FoldInput -eq $false -and [string]::IsNullOrWhiteSpace($point) -eq $false) {
        $loc = $point -split ","
        $Dot = [PSCustomObject]@{
            'x' = [int]::Parse($loc[0])
            'y' = [int]::Parse($loc[1])
        }
        $DotArray.Add($Dot) | Out-Null
    }
    else {
        # We've reached a blank line and the folds have begun, but skip the blank line
        $FoldInput = $true
        if ([string]::IsNullOrWhiteSpace($point)) {
            continue
        }
        # Split up the line by spaces, take the 3rd item and split on the = character to get the axis and position of the fold
        $FoldData = ($point -split " ")[2] -split "="
        $Fold = [PSCustomObject]@{
            'Axis' = $FoldData[0]
            'Pos' = [int]::Parse($FoldData[1])
        }
        $FoldList.Add($Fold) | Out-Null
    }
}

function Get-DotImage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object[]]
        $DotArray
    )
    # Get the maximum size of the grid in each direction
    $XMax = ($DotArray.x | Measure-Object -Maximum).Maximum
    $YMax = ($DotArray.y | Measure-Object -Maximum).Maximum

    for($y=0; $y -le $YMax; $y++) {
        $OutputString = ""
        for($x=0; $x -le $XMax; $x++) {
            if(($DotArray | Where-Object {$_.x -eq $x -and $_.y -eq $y}).Count -ne 0) {
                $OutputString += "#"
            }
            else {
                $OutputString += "."
            }
        }
        Write-Host $OutputString
    }
}

function Invoke-Fold {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        [ValidateSet("x","y")]
        $Axis,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]
        [Alias("Pos")]
        $Location,

        [Parameter()]
        [System.Collections.ArrayList]
        $DotArray
    )

    process {
        if ($Axis -eq "y") {
            $SortedRelevantDots = $DotArray | Where-Object {$_.y -gt $Location}
            foreach ($Dot in $SortedRelevantDots) {
                $NewY = $Location - ($Dot.y - $Location)
                $DotArray += [PSCustomObject]@{
                    'x' = $Dot.x
                    'y' = $NewY
                }
                $DotArray.Remove($Dot)
            }
        }
        else {
            $SortedRelevantDots = $DotArray | Where-Object {$_.x -gt $Location}
            foreach ($Dot in $SortedRelevantDots) {
                $NewX = $Location - ($Dot.x - $Location)
                $DotArray += [PSCustomObject]@{
                    'x' = $NewX
                    'y' = $Dot.y
                }
                $DotArray.Remove($Dot)
            }
        }
    }
    end {
        return $DotArray
    }
}

# For Part 1 change to $FoldList[0] to perform first fold only.
$DotArray = $FoldList | Invoke-Fold -DotArray $DotArray

$result = ($DotArray | Group-Object -Property x,y).Count

Get-DotImage -DotArray $DotArray
$result
$result | Set-Clipboard