class Fish {
    [int]$Timer

    Fish(
        [int]$a
    ){
        $this.Timer = $a
    }

    Fish()
    {
        $this.Timer = 8
    }

    [bool]Age() {
        $didBirth = $false
        if ($this.Timer -eq 0) {
            $this.Timer = 6
            $didBirth = $true
        } else {
            $this.Timer = $this.Timer - 1
        }
        return $didBirth
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
        [System.Collections.ArrayList]$FishState = @()
        foreach ($fish in $InitialState) {
            $FishState.Add([Fish]::new($fish)) | Out-Null
        }
    }

    process {
        for($i=0; $i -lt $Days; $i++) {
            $births = 0
            foreach ($fish in $FishState) {
                if ($fish.Age()) {
                    $births = $births + 1
                }
            }
            for($j=0; $j -lt $births; $j++) {
                $FishState.Add([Fish]::new()) | Out-Null
            }
        }
        
    }

    end {
        $FishState.Count
    }
}

$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$FishData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")) -split ","

Get-FishCount -Days 256 -InitialState $FishData