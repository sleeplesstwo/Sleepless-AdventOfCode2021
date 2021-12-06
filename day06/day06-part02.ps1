# Just track the school as a whole and track how many fish are in each day state.
class School {
    [long]$Day0
    [long]$Day1
    [long]$Day2
    [long]$Day3
    [long]$Day4
    [long]$Day5
    [long]$Day6
    [long]$Day7
    [long]$Day8

    School()
    {
        $this.Day0 = 0
        $this.Day1 = 0
        $this.Day2 = 0
        $this.Day3 = 0
        $this.Day4 = 0
        $this.Day5 = 0
        $this.Day6 = 0
        $this.Day7 = 0
        $this.Day8 = 0
    }
    [void]AddFish([int]$a, [int]$count) {
        switch ($a) {
            0 { $this.Day0 = $this.Day0 + $count}
            1 { $this.Day1 = $this.Day1 + $count}
            2 { $this.Day2 = $this.Day2 + $count}
            3 { $this.Day3 = $this.Day3 + $count}
            4 { $this.Day4 = $this.Day4 + $count}
            5 { $this.Day5 = $this.Day5 + $count}
            6 { $this.Day6 = $this.Day6 + $count}
            7 { $this.Day7 = $this.Day7 + $count}
            8 { $this.Day8 = $this.Day8 + $count}
        }
    }
    [long]SumFish() {
        $totalFish = $this.Day0 + $this.Day1 + $this.Day2 + $this.Day3 + $this.Day4 + $this.Day5 + $this.Day6 + $this.Day7 + $this.Day8
        return $totalFish
    }
    [object]Age() {
        $births = $this.Day0
        $NewDay0 = $this.Day1
        $NewDay1 = $this.Day2
        $NewDay2 = $this.Day3
        $NewDay3 = $this.Day4
        $NewDay4 = $this.Day5
        $NewDay5 = $this.Day6
        $NewDay6 = $this.Day7 + $this.Day0
        $NewDay7 = $this.Day8

        $this.Day0 = $NewDay0
        $this.Day1 = $NewDay1
        $this.Day2 = $NewDay2
        $this.Day3 = $NewDay3
        $this.Day4 = $NewDay4
        $this.Day5 = $NewDay5
        $this.Day6 = $NewDay6
        $this.Day7 = $NewDay7
        $this.Day8 = $births

        return $this
    }
}

function Get-FishCount {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Days,

        [Parameter()]
        [int[]]
        $InitialState
    )

    begin {
        $SchoolState = [School]::new()
        foreach ($item in ($InitialState | Group-Object)) {
            $SchoolState.AddFish($item.Name, $item.Count)
        }
        $SchoolState
    }

    process {
        for($i=0; $i -lt $Days; $i++) {
            $SchoolState.Age()
        }
        
    }

    end {
        $SchoolState.SumFish()
    }
}

$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$FishData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")) -split ","

Get-FishCount -Days 256 -InitialState $FishData