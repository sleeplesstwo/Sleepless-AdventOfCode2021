$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$PacketData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$BinaryString = ""
foreach ($value in $PacketData.toCharArray()) {
    $BinaryValue = ([Convert]::ToString(([Convert]::ToInt64($value, 16)), 2)).PadLeft(4,"0")
    $BinaryString += $BinaryValue 
}


#$BinaryString = [Convert]::ToString(([Convert]::ToInt64($PacketData, 16)), 2)

$DataStream = [System.Collections.Generic.Queue[int]]::new()
    $StringArray = $BinaryString.ToCharArray()
    foreach ($bitValue in $StringArray) {
        $bitValue = [int]::Parse($bitValue)
        $DataStream.Enqueue($bitValue)
    }

function Import-PacketData {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Collections.Generic.Queue[int]]
        $DataStream,

        [Parameter()]
        $PacketCount = $null
    )

    [System.Collections.ArrayList]$PacketOutput = @()
    while ($DataStream.Count -gt 0) {
        $Version = ""
        for ($i = 0; $i -lt 3; $i++) {
            $Version += $DataStream.Dequeue()
        }
        $Version = [Convert]::ToInt32($Version, 2)
        $ID = ""
        for ($i = 0; $i -lt 3; $i++) {
            $ID += $DataStream.Dequeue()
        }
        $ID = [Convert]::ToInt32($ID, 2)

        if ($ID -eq 4) {
            # This is a literal value packet
            $LastValue = $false
            $Value = ""
            while (-not $LastValue) {
                if ($DataStream.Dequeue() -eq 0) {
                    $LastValue = $true
                }
                for ($i = 0; $i -lt 4; $i++) {
                    $Value += $DataStream.Dequeue()
                }
            }
            $Value = [Convert]::ToInt64($Value, 2)
            $PacketOutput.Add([PSCustomObject]@{
                'Version' = $Version
                'ID'      = $ID
                'Value'   = $Value
            }) | Out-Null
                if ($null -ne $PacketCount) {
                    $PacketCount--
                }
        }
        else {
            # This is an operator packet
            if ($DataStream.Dequeue() -eq 0) {
                # The next 15 bits represents the total length in bits of subpackets.
                $TotalLength = ""
                for ($i=0; $i -lt 15; $i++) {
                    $TotalLength += $DataStream.Dequeue()
                }
                $TotalLength = [Convert]::ToInt32($TotalLength, 2)
                $SubPacketData = [System.Collections.Generic.Queue[int]]::new()
                for ($i=0; $i -lt $TotalLength; $i++) {
                    $SubPacketData.Enqueue($DataStream.Dequeue())
                }
                $SubPacketResult = Import-PacketData -DataStream $SubPacketData
                $PacketOutput.Add([PSCustomObject]@{
                    'Version' = $Version
                    'ID'      = $ID
                    'Value'   = @($SubPacketResult)
                }) | Out-Null
                if ($null -ne $PacketCount) {
                    $PacketCount--
                }

            } else {
                # The next 11 bits represent the number of subpackets in this packet.
                $SubPacketCount = ""
                for ($i=0; $i -lt 11; $i++) {
                    $SubPacketCount += $DataStream.Dequeue()
                }
                $SubPacketCount = [Convert]::ToInt32($SubPacketCount, 2)

                $SubPacketResult = Import-PacketData -DataStream $DataStream -PacketCount $SubPacketCount

                $PacketOutput.Add([PSCustomObject]@{
                    'Version' = $Version
                    'ID'      = $ID
                    'Value'   = @($SubPacketResult)
                }) | Out-Null
                if ($null -ne $PacketCount) {
                    $PacketCount--
                }
            }
        }

        if ($PacketCount -eq 0) {
            return $PacketOutput
        }


        if ($DataStream.Count -lt 11) {
            $DataStream.Clear()
        }
    }
    return $PacketOutput
    
}


$PacketResults = Import-PacketData -DataStream $DataStream

function Get-PacketVersionSum {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object[]]
        $PacketObjects
    )

    $VersionTotal = 0
    foreach ($item in $PacketObjects) {
        $VersionTotal += $item.Version
        if ($item.value.getType().Name -eq "Object[]") {
            $VersionTotal += Get-PacketVersionSum -PacketObjects $item.Value
        }
    }
    return $VersionTotal
}

$results = Get-PacketVersionSum -PacketObjects $PacketResults

$results
$results | Set-Clipboard