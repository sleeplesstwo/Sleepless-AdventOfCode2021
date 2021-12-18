$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$InputData = (Get-Content -Path (Join-Path $BasePath -ChildPath "testinput.txt"))

[System.Collections.ArrayList]$SnailfishList = @()

function New-Pair {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $PairID,

        [Parameter()]
        [string]
        $ParentID = $null
    )
    $ReturnObject = [PSCustomObject]@{
        'LeftValue'  = $null
        'RightValue' = $null
        'PairID'     = $PairID
        'ParentID'   = $ParentID
    }
    while ($DataStream.Count -gt 0) {
        $NextChar = $DataStream.Dequeue()
        if ($NextChar -eq "[") {
            $Global:PairID++
            $ReturnObject.LeftValue = New-Pair -PairID ("$Global:PairID" + "L") -ParentID $ReturnObject.PairID
        }
        elseif ($NextChar -match "\d") {
            $ReturnObject.LeftValue = [int]::Parse($NextChar)
        }
        elseif ($NextChar -eq ",") {
            $NextChar = $DataStream.Dequeue()
            if ($NextChar -eq "[") {
                $ReturnObject.RightValue = New-Pair -PairID ("$Global:PairID" + "R") -ParentID $ReturnObject.PairID
            }
            elseif ($NextChar -match "\d") {
                $ReturnObject.RightValue = [int]::Parse($NextChar)
            }
        }
        elseif ($NextChar -eq "]") {
            return $ReturnObject
        }
    }
    return $ReturnObject
}

function Test-Explosions {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object]
        $InputObject,

        [Parameter()]
        [int]
        $Depth = 1,

        [Parameter()]
        [string]
        $PathToExplosion = ""

    )

    $LeftValue = $null
    $RightValue = $null
    $ExplosionID = $null

    if ($InputObject.LeftValue.GetType().Name -eq "PSCustomObject") {
        $PathToExplosion += "L"
        $ExplosionID, $LeftValue, $RightValue, $Side = Test-Explosions $InputObject.LeftValue -Depth ($Depth + 1) -PathToExplosion $PathToExplosion
    }
    if ($InputObject.RightValue.GetType().Name -eq "PSCustomObject" -and $null -eq $ExplosionID) {
        $PathToExplosion += "R"
        $ExplosionID, $LeftValue, $RightValue, $Side = Test-Explosions $InputObject.RightValue -Depth ($Depth + 1) -PathToExplosion $PathToExplosion
    }
    if ($Depth -gt 4 -and $null -eq $LeftValue -and $null -eq $RightValue) {
        $LeftValue = $InputObject.LeftValue
        $RightValue = $InputObject.RightValue
        $ExplosionID = $InputObject.PairID
        $Side = $InputObject.PairID.Substring($InputObject.PairID.Length - 1)
        return $ExplosionID, $LeftValue, $RightValue, $Side
    }
    if ($null -ne $RightValue -and $Side -eq "L") {
        if ($null -ne $LeftValue) {
            $InputObject.LeftValue = 0
        }
        if ($InputObject.RightValue.GetType().Name -ne "PSCustomObject") {
            $InputObject.RightValue += $RightValue
            $RightValue = $null
        } 
        else {
            $InputObject.RightValue = Set-ChildValue -Side $Side -InputObject $InputObject.RightValue -Value $RightValue
            $RightValue = $null
        }
    }
    elseif ($null -ne $LeftValue -and $Side -eq "R") {
        if ($null -ne $RightValue) {
            $InputObject.RightValue = 0
        }
        if ($InputObject.LeftValue.GetType().Name -ne "PSCustomObject") {
            $InputObject.LeftValue += $LeftValue
            $LeftValue = $null
        }
        else {
                
            $InputObject.LeftValue = Set-ChildValue -Side $Side -InputObject $InputObject.LeftValue
        }
    }
    if ([string]::IsNullOrWhiteSpace($InputObject.ParentID)) {
        return $InputObject, $ExplosionID
    }
    else {
        $Side = $InputObject.PairID.Substring($InputObject.PairID.Length - 1)
        return $ExplosionID, $LeftValue, $RightValue, $Side
    }
}

function Test-Splits {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object]
        $InputObject
    )
    $HadSplitLeft = $false
    $HadSplitRight = $false

    if ($InputObject.LeftValue.GetType().Name -eq "PSCustomObject") {
        $InputObject.LeftValue, $HadSplitLeft = Test-Splits $InputObject.LeftValue
    }
    elseif ($InputObject.LeftValue -gt 9) {
        $Global:PairID++
        $LeftValue = [math]::Floor(($InputObject.LeftValue / 2))
        $RightValue = [math]::Ceiling(($InputObject.LeftValue / 2))
        $NewPair = [PSCustomObject]@{
            'LeftValue'  = $LeftValue
            'RightValue' = $RightValue
            'PairID'     = "$($Global:PairID)" + "L"
            'ParentID'   = $InputObject.PairID
        }
        $InputObject.LeftValue = $NewPair
        $HadSplitLeft = $True
    }
    if ($InputObject.RightValue.GetType().Name -eq "PSCustomObject") {
        $InputObject.RIghtValue, $HadSplitRight = Test-Splits $InputObject.RightValue
    }
    elseif ($InputObject.RightValue -gt 9) {
        $Global:PairID++
        $LeftValue = [math]::Floor(($InputObject.RightValue / 2))
        $RightValue = [math]::Ceiling(($InputObject.RightValue / 2))
        $NewPair = [PSCustomObject]@{
            'LeftValue'  = $LeftValue
            'RightValue' = $RightValue
            'PairID'     = "$($Global:PairID)" + "R"
            'ParentID'   = $InputObject.PairID
        }
        $InputObject.RightValue = $NewPair
        $HadSplitRight = $True
    }
    return $InputObject, ($HadSplitLeft -or $HadSplitRight)
}

function Set-ChildValue {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Side,

        [Parameter()]
        [object]
        $InputObject,

        [Parameter()]
        [int]
        $Value
    )

    if ($Side -eq "L") {
        if ($InputObject.LeftValue.GetType().Name -ne "PSCUstomObject") {
            $InputObject.LeftValue += $Value
            $RightValue = $null
        } 
        else {
            $InputObject.LeftValue = Set-ChildValue -Side $Side -InputObject $InputObject.LeftValue
        }
    }
    if ($Side -eq "R") {
        if ($InputObject.RightValue.GetType().Name -ne "PSCUstomObject") {
            $InputObject.RightValue += $Value
            $RightValue = 0
        } 
        else {
            $InputObject.RightValue = Set-ChildValue -Side $Side -InputObject $InputObject.RightValue
        }
    }
    return $InputObject
}

function Get-Magnatude {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Object]
        $InputObject
    )

    if ($InputObject.LeftValue.GetType().Name -eq "PSCustomObject") {
        $LeftValue = (Get-Magnatude $InputObject.LeftValue) * 3
    }
    else {
        $LeftValue = $InputObject.LeftValue * 3
    }
    if ($InputObject.RightValue.GetType().Name -eq "PSCUstomObject") {
        $RightValue = (Get-Magnatude $InputObject.RightValue) * 2
    }
    else {
        $RightValue = $InputObject.RightValue * 2
    }

    return $LeftValue + $RightValue
}

function Add-SnailFishNumber {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object]
        $InputObject,

        [Parameter()]
        [object]
        $AddObject
    )

    $Global:PairID++
    $InputObject.ParentID = $Global:PairID
    $InputObject.PairID = "$($InputObject.PairID)" + "L"
    if ($InputObject.LeftValue.GetType().Name -eq "PSCustomObject") {
        $InputObject.LeftValue.ParentID = $InputObject.PairID
    }
    if ($InputObject.LeftValue.GetType().Name -eq "PSCustomObject") {
        $InputObject.RightValue.ParentID = $InputObject.PairID
    }
    

    $AddObject.ParentID = $Global:PairID
    $AddObject.PairID = "$($AddObject.PairID)" + "R"
    if ($AddObject.LeftValue.GetType().Name -eq "PSCustomObject") {
        $AddObject.LeftValue.ParentID = $AddObject.PairID
    }
    if ($AddObject.RightValue.GetType().Name -eq "PSCustomObject") {
        $AddObject.RightValue.ParentID = $AddObject.PairID
    }

    $ReturnObject = [PSCustomObject]@{
        'LeftValue'  = $InputObject
        'RightValue' = $AddObject
        'PairID'     = $Global:PairID
        'ParentID'   = $null
    }
    return $ReturnObject
}

function Get-SnailFishString {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object]
        $InputObject
    )

    $OutputString = "["
    if ($InputObject.LeftValue.GetType().Name -eq "PSCustomObject") {
        $OutputString += Get-SnailFishString -InputObject $InputObject.LeftValue
    }
    else {
        $OutputString += "$($InputObject.LeftValue)"
    }
    $OutputString += ","
    if ($InputObject.RightValue.GetType().Name -eq "PSCustomObject") {
        $OutputString += Get-SnailFishString -InputObject $InputObject.RightValue
    }
    else {
        $OutputString += "$($InputObject.RightValue)"
    }

    $OutputString += "]"
    return $OutputString

}
$Global:PairID = 0
$Line = $InputData[0]
$DataStream = [System.Collections.Generic.Queue[char]]::new()
$LineArray = $line.ToCharArray()
foreach ($character in $LineArray) {
    $DataStream.Enqueue($character)
}
$DataStream.Dequeue() | Out-Null
$Global:PairID++
$MainObject = New-Pair -PairID $Global:PairID

for ($i = 1; $i -lt $InputData.Count; $i++) {
    $AddObjectLine = $InputData[$i]
    $DataStream = [System.Collections.Generic.Queue[char]]::new()
    $LineArray = $AddObjectLine.ToCharArray()
    foreach ($character in $LineArray) {
        $DataStream.Enqueue($character)
    }
    $DataStream.Dequeue() | Out-Null
    $Global:PairID++
    $AddObject = New-Pair -PairID $Global:PairID

    $MainObject = Add-SnailFishNumber -InputObject $MainObject -AddObject $AddObject

    $ExplodeOrSplit = $true
    while ($ExplodeOrSplit) {
        $ExplosionID = ""
        $DidExplosion = $false
        $DidSplit = $false
        while ($null -ne $ExplosionID) {
            $MainObject, $ExplosionID = Test-Explosions -InputObject $MainObject
            if ($null -ne $ExplosionID) {
                $DidExplosion = $true
            }        
        }

        $HadSplit = $true
        while ($HadSplit) {
            $MainObject, $HadSplit = Test-Splits -InputObject $MainObject
            if ($HadSplit) {
                $DidSplit = $true
            }
        }
        if (-not $DidExplosion -and -not $DidSplit) {
            $ExplodeOrSplit = $false
        }
    } 
}


Get-SnailFishString -InputObject $MainObject