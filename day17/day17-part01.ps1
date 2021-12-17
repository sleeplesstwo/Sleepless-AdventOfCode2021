$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$InputData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$xpos = $InputData.IndexOf("x") + 2
$split = $InputData.IndexOf(",")
$ypos = $InputData.IndexOf("y") + 2

$XRange = $InputData.Substring($xpos, ($split - $xpos)) -split "\.\."
$YRange = $InputData.Substring($ypos) -split "\.\."

$Global:XMin = ($XRange | Measure-Object -Minimum).Minimum
$Global:XMax = ($XRange | Measure-Object -Maximum).Maximum
$Global:YMin = ($YRange | Measure-Object -Minimum).Minimum
$Global:YMax = ($YRange | Measure-Object -Maximum).Maximum

function Get-ProbePosition {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $XVelocity,

        [Parameter()]
        [int]
        $YVelocity
    )

    $ProbeInfo = [PSCustomObject]@{
        'XPos'      = 0
        'YPos'      = 0
        'XVelocity' = $XVelocity
        'YVelocity' = $YVelocity
    }
    $Success = $false
    $ProbePastTargetArea = $false
    $Step = 0
    [System.Collections.ArrayList]$PositionList = @()

    while (-not $ProbePastTargetArea) {
        $PositionList.Add($ProbeInfo.psobject.Copy()) | Out-Null
        if ($ProbeInfo.XPos -gt $Global:XMax -or $ProbeInfo.YPos -lt $Global:YMin) {
            # Probe passed target area
            $ProbePastTargetArea = $true
            if (-not $Success) {
                throw "Probe never entered target area"
            }
        }
        elseif ($ProbeInfo.XPos -ge $XMin -and $ProbeInfo.YPos -ge $YMin -and $ProbeInfo.XPos -le $XMax -and $ProbeInfo.YPos -le $YMax) {
            # Probe entered target area
            return $PositionList
            $Success = $true
        }

        if ($ProbeInfo.XPos -lt $Global:XMin -and $ProbeInfo.XVelocity -eq 0) {
            throw "Probe needs more XVelocity"
        }
        $Step++
        $ProbeInfo.XPos += $ProbeInfo.XVelocity
        $ProbeInfo.YPos += $ProbeInfo.YVelocity
        if ($ProbeInfo.XVelocity -ne 0) {
            if ($ProbeInfo.XVelocity -gt 0) {
                $ProbeInfo.XVelocity--
            } else {
                $ProbeInfo.XVelocity++
            }
        }
        $ProbeInfo.YVelocity--
    }
}

function Test-InitialVelocity {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        [ValidateSet("x","y")]
        $Axis,

        [Parameter()]
        [int]
        $InitialVelocity
    )

    if ($Axis -eq "x") {
        $Min = $Global:XMin
        $Max = $Global:XMax
    }
    else {
        $Min = $Global:YMin
        $Max = $Global:YMax
    }

    $Position = 0
    $Complete = $false
    $Velocity = $InitialVelocity
    while (-not $Complete) {
        if ($Axis -eq "x") {
            $Position = $Position + $Velocity
            if ($Velocity -ne 0) {
                $Velocity--
            }
            if ($Position -gt $Max) {
                return $false
                $Complete = $true
            } elseif ($Position -ge $Min -and $Position -le $Max) {
                return $true
                $Complete = $true
            } elseif ($Position -lt $Min -and $Velocity -eq 0) {
                return $false
                $Complete = $true
            }
        } else {
            $Position = $Position + $Velocity
            $Velocity--
            if ($Position -lt $Min) {
                return $false
                $Complete = $true
            } elseif ($Position -ge $Min -and $Position -le $Max) {
                return $true
                $Complete = $true
            }
        }
    }
}

$ValidYVelocities = @()
foreach ($vel in @(1..1000)) {
    if (Test-InitialVelocity -Axis "y" -InitialVelocity $vel) {
        $ValidYVelocities += $vel
    }
}

$vel = 1
while ((Test-InitialVelocity -Axis "x" -InitialVelocity $vel) -eq $false) {
    $vel++
}
$ValidXVelocities = $vel

$positions = Get-ProbePosition -XVelocity $ValidXVelocities -YVelocity ($ValidYVelocities | Measure-Object -Maximum).Maximum

$result = ($positions | Measure-Object -Property YPos -Maximum).Maximum

$result
$result | Set-Clipboard