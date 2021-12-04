#Lets make classes for the board parts

#Square tracks if it's been selected, what row/column and it's value
class Square {
    [int]$ColNum
    [int]$RowNum
    [int]$value
    [bool]$selected

    Square(
        [int]$SqVal,
        [int]$ColNum,
        [int]$RowNum
    ) {
        $this.value = $SqVal
        $this.ColNum = $ColNum
        $this.RowNum = $RowNum
        $this.selected = $false
    }
}

# Row contains an array of squares and it's row number
class Row {
    [int]$RowNum
    [Square[]]$ColData

    Row(
        [int]$RowNum
    ) {
        $this.RowNum = $RowNum
    }
    
    [void]AddCol([int]$ColVal, [int]$ColNum) {
        $a = $this.RowNum
        $this.ColData += [Square]::new($ColVal, $ColNum, $a)
    }
}

#Board consists of multiple rows
class Board {
    [int]$BoardID
    [Row[]]$RowData

    Board(
        [int]$BoardID
    ) {
        $this.BoardID = $BoardID
    }

    [void]AddRow([Row]$RowData) {
        $this.RowData += $RowData
    }
}

function Import-Board {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$Offset,
        
        [Parameter()]
        [string[]]$Inputdata
    )
    # Initialize a new board object give it an ID of the offset.
    $Board = [Board]::new($Offset)
    for($i=0; $i -lt 5; $i++) {
        # Input each line starting from the offset
        # Trim whitespace from ends of string then split at whitespace
        $line = ($Inputdata[$i+$Offset]).trim() -split '\s+'

        # Initalize a row object with RowNum of i
        $RowData = [Row]::new($i)
        for($j=0; $j -lt 5; $j++) {
            # Add the squares into the row.
            $RowData.AddCol($line[$j], $j)
        }

        # Add the row to the board
        $Board.AddRow($RowData)
    }

    # Return the completed board object
    return $Board
}

function Update-Board {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Number,

        [Parameter()]
        [Board[]]$Boards
    )

    # Take an array of boards and for each
    foreach ($Board in $Boards) {
        # Find every square that matches the input number
        $itemToUpdate = $Board.RowData.ColData | Where-Object { $_.Value -eq $Number }

        # If there is any matches, set the selected value to true.
        if ($null -ne $itemToUpdate) {
            $itemToUpdate.selected = $true
        }
    }
}

function Test-Boards {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Board[]]$Boards
    )

    #Initialize an empty array to track what boards won this round
    $WinningBoards = @()
    foreach ($Board in $Boards) {
        # Test Rows
        for ($i = 0; $i -lt 5; $i++) {
            # Step through each row and check to see if none are false
            if (($Board.RowData.ColData | Where-Object { $_.RowNum -eq $i }).selected -notcontains $false) {
                #If not add the boardID to list of winning boards this round
                $WinningBoards += $Board.BoardID
            }
        }
        # Test Columns
        for ($i = 0; $i -lt 5; $i++) {
            # Step through each row and check to see if none are false
            if (($Board.RowData.ColData | Where-Object { $_.ColNum -eq $i }).Selected -notcontains $false) {
                #If not add the boardID to list of winning boards this round
                $WinningBoards += $Board.BoardID
            }
        }
    }
    # If any boards have won this round return the array, othewise return null.
    if ($WinningBoards.Count -gt 0) {
        return $WinningBoards
    } else {
        return $null
    }
}

$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

#$BoardData = Get-Content -Path ".\testboardinput.txt"
#$SelectionData = (Get-Content -Path ".\testselectioninput.txt") -split ","

$BoardData = Get-Content -Path (Join-Path $BasePath -ChildPath "boardinput.txt")
$SelectionData = (Get-Content -Path (Join-Path $BasePath -ChildPath "selectioninput.txt")) -split ","

# How many boards are there, 6 lines per including the seperating blank line
$TotalLines = $BoardData.Count
$TotalBoards = $TotalLines / 6

# Initialize an empty array to hold all the boards
$Boards = @()

# Import each board into the array
for ($i = 0; $i -lt $TotalBoards; $i++) {
    $Boards += Import-Board -Offset ($i * 6) -Inputdata $BoardData
}

# Start going through each number in the selection data
foreach ($call in $SelectionData) {
    # Update all the boards with the called number
    Update-Board -Number $call -Boards $Boards
    
    # Test the boards to see if any have won
    $IsWinner = Test-Boards $Boards

    # If test returned a non null value then something won
    if ($null -ne $IsWinner) {
        # If the current count is greater than 1 filter out the winning boardIDs
        if ($Boards.Count -gt 1) {
            $Boards = $Boards | Where-Object {$_.BoardID -notin $IsWinner}
        }
        else {
            # Otherwise 1 board left means it's the last winner
            # Calculate the sum of numbers on the board that aren't selected yet
            $BoardScore = ($Boards.RowData.ColData | Where-Object { $_.selected -eq $false } | Measure-Object -Property "value" -Sum).Sum
            
            # Multiply result by the last called number
            $result = $BoardScore * $call
            $result
            $result | Set-Clipboard

            # Break out of the loop so continue checking the rest of the call numbers
            break
        }
    }
}

