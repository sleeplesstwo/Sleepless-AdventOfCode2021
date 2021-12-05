function New-GridData {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$Size
    )

    $GridArray = [System.Collections.ArrayList]@()
    for ($i = 0; $i -lt $Size; $i++) {
        $RowArray = [int[]]::new($Size)
        $GridArray.Add($RowArray) | Out-Null
    }

    return $GridArray
}

function Import-DataPoints {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Path
    )

    $ImportContent = Get-Content -Path $Path
    $OutputObjects = [System.Collections.ArrayList]@()
    foreach ($line in $ImportContent) {
        $dataArray = $line -split " -> " -split ","
        $lineObject = [PSCustomObject]@{
            'StartX' = $dataArray[0]
            'StartY' = $dataArray[1]
            'EndX'   = $dataArray[2]
            'EndY'   = $dataArray[3]
        }
        
        $OutputObjects.Add($lineObject) | Out-Null
    }
    return $OutputObjects
}

function Set-GridData {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]
        $StartX,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]
        $StartY,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]
        $EndX,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]
        $EndY,

        [Parameter()]
        [Object[]]
        $GridData

    )

    process {
        #Check for horizontal match
        if ($StartX -eq $EndX) {
            Write-Debug "Y Change: $StartY, $EndY"
            if ($StartY -lt $EndY) {
                for ($i = $StartY; $i -le $EndY; $i++) {
                    $GridData[$i][$StartX] = $GridData[$i][$StartX] + 1
                }
            }
            else {
                for ($i = $EndY; $i -le $StartY; $i++) {
                    $GridData[$i][$StartX] = $GridData[$i][$StartX] + 1
                }
            }
        }

        #Check for vertical match
        if ($StartY -eq $EndY) {
            Write-Debug "X Change on YIndex $StartY XFrom $StartX, $EndX"
            if ($StartX -lt $EndX) {
                for ($i = $StartX; $i -le $EndX; $i++) {
                    $GridData[$StartY][$i] = $GridData[$StartY][$i] + 1
                }
            }
            else {
                for ($i = $EndX; $i -le $StartX; $i++) {
                    $GridData[$StartY][$i] = $GridData[$StartY][$i] + 1
                }
            }
        }

        #Check for 45 degree diagonal match
        $XChange = [Math]::Abs($StartX - $EndX)
        $YChange = [Math]::Abs($StartY - $EndY)
        
        if ($XChange -eq $YChange) {
            Write-Debug "Diagonal: $XChange"
            for ($i = 0; $i -le $XChange; $i++) {
                if ($StartX -lt $EndX) {
                    if ($StartY -lt $EndY) {
                        # 45 degree down right
                            $XIndex = $StartX + $i
                            $YIndex = $StartY + $i
                    } else {
                        # 45 degree up right
                        $XIndex = $StartX + $i
                        $YIndex = $StartY - $i
                    }
                } else {
                    if ($StartY -lt $EndY) {
                        # 45 degree down left
                        $XIndex = $StartX - $i
                        $YIndex = $StartY + $i
                    } else {
                        # 45 degree up left
                        $XIndex = $StartX - $i
                        $YIndex = $StartY - $i
                    }
                }
                Write-Debug "Changing Index: $XIndex, $YIndex"
                $GridData[$YIndex][$XIndex] = $GridData[$YIndex][$XIndex] + 1
            }
            
        }
    }
    end {
        return $GridData
    }
    
}

$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$Grid = New-GridData -Size 1000
$DataPoints = Import-DataPoints -Path (Join-Path $BasePath -ChildPath "input.txt")

$NewTestData = $DataPoints | Set-GridData -GridData $Grid

$DangerCount = 0
foreach ($line in $NewTestData) {
    $DangerCount = $DangerCount + ($line | Where-Object {$_ -ge 2}).Count
}

$DangerCount
$DangerCount | Set-Clipboard