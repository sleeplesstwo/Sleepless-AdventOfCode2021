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
    $Board = [Board]::new($Offset)
    for($i=0; $i -lt 5; $i++) {
        $line = ($Inputdata[$i+$Offset]).trim() -split '\s+'
        $RowData = [Row]::new($i)
        for($j=0; $j -lt 5; $j++) {
            $RowData.AddCol($line[$j], $j)
        }
        $Board.AddRow($RowData)
    }

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
    foreach ($Board in $Boards) {
        $itemToUpdate = $Board.RowData.ColData | Where-Object {$_.Value -eq $Number}

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
            if (($Board.RowData.ColData | Where-Object { $_.RowNum -eq $i }).selected -notcontains $false) {
                return $Board.BoardID
            }
        }
        # Test Columns
        for ($i = 0; $i -lt 5; $i++) {
            if (($Board.RowData.ColData | Where-Object { $_.ColNum -eq $i }).Selected -notcontains $false) {
                return $Board.BoardID
            }
        }
    }
    return $null
}

$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

#$BoardData = Get-Content -Path ".\testboardinput.txt"
#$SelectionData = (Get-Content -Path ".\testselectioninput.txt") -split ","

$BoardData = Get-Content -Path (Join-Path $BasePath -ChildPath "boardinput.txt")
$SelectionData = (Get-Content -Path (Join-Path $BasePath -ChildPath "selectioninput.txt")) -split ","

$TotalLines = $BoardData.Count
$TotalBoards = $TotalLines / 6
$Boards = @()
for($i=0;$i -lt $TotalBoards; $i++) {
    $Boards += Import-Board -Offset ($i * 6) -Inputdata $BoardData
}

foreach ($call in $SelectionData) {
    Update-Board -Number $call -Boards $Boards
    $IsWinner = Test-Boards $Boards
    if ($null -ne $IsWinner) {
        break
    }
}

$WinningBoard = $Boards | Where-Object {$_.BoardID -eq $IsWinner}

$BoardScore = ($WinningBoard.RowData.ColData | Where-Object {$_.selected -eq $false} | Measure-Object -Property "value" -Sum).Sum

$result = $BoardScore * $call

$result