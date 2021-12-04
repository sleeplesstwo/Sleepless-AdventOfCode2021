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
    ){
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
    ){
        $this.RowNum = $RowNum
    }
    
    [void]AddCol([int]$ColVal, [int]$ColNum)
    {
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
    ){
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
        $itemToUpdate = $Board.RowData.ColData | Where-Object {$_.Value -eq $Number}

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

    foreach ($Board in $Boards) {
        # Test Rows
        for ($i = 0; $i -lt 5; $i++) {
            # Step through each row and check to see if none are false and if not return the boardID
            if (($Board.RowData.ColData | Where-Object { $_.RowNum -eq $i }).selected -notcontains $false) {
                return $Board.BoardID
            }
        }
        # Test Columns
        for ($i = 0; $i -lt 5; $i++) {
            # Step through each column and check to see if none are false and if not return the boardID
            if (($Board.RowData.ColData | Where-Object { $_.ColNum -eq $i }).Selected -notcontains $false) {
                return $Board.BoardID
            }
        }
    }
    # No winning rows/columns so return null value.
    return $null
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
for($i=0;$i -lt $TotalBoards; $i++) {
    $Boards += Import-Board -Offset ($i * 6) -Inputdata $BoardData
}

# Start going through each number in the selection data
foreach ($call in $SelectionData) {
    # Update all the boards with the called number
    Update-Board -Number $call -Boards $Boards

    # Test the boards to see if any have won
    $IsWinner = Test-Boards $Boards

    # Non null means we've found a winner
    if ($null -ne $IsWinner) {
        break
    }
}

# Get the winning board and sum all the values that haven't been selected
$WinningBoard = $Boards | Where-Object {$_.BoardID -eq $IsWinner}
$BoardScore = ($WinningBoard.RowData.ColData | Where-Object {$_.selected -eq $false} | Measure-Object -Property "value" -Sum).Sum

# Multiply result by the called number for result
$result = $BoardScore * $call
$result
$result | Set-Clipboard