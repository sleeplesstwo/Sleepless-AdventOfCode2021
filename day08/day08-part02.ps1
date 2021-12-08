$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

#$SegmentData = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf" | ConvertFrom-CSV -Delimiter "|" -Header "Signal", "Output"
$SegmentData = Import-CSV -Path (Join-Path $BasePath -ChildPath "input.txt") -Delimiter "|" -Header "Signal","Output"

$OutputData = foreach ($line in $SegmentData) {
    $line.Signal, $line.Output -join ""
}
$result = 0

foreach ($line in $SegmentData) {
    $SortedLength = $line.Signal -split " " | Group-Object -Property Length

    foreach ($item in $SortedLength) {
        switch ($item.Name) {
            2 {
                # Digit 1 found
                Write-Host "1 Found"
                $OneSegments = ($item.Group.ToCharArray() | Sort-Object) -join ""
                break
            }
            3 {
                # Digit 7 found
                Write-Host "7 Found"
                $SevenSegments = ($item.Group.ToCharArray() | Sort-Object)
                break
            }
            4 {
                # Digit 4 found
                Write-Host "4 Found"
                $FourSegments = ($item.Group.ToCharArray() | Sort-Object)
                break
            }
            7 {
                # Digit 8 found
                Write-Host "8 Found"
                $EightSegments = ($item.Group.ToCharArray() | Sort-Object) -join ""
                break
            }
            6 {
                foreach ($set in $item.Group) {
                    
                    $setArray = $set.ToCharArray() | Sort-Object
                    $Matches = Compare-Object -ReferenceObject $setArray -DifferenceObject $SevenSegments -IncludeEqual | Where-Object {$_.SideIndicator -eq "=="}
                    if ($Matches.Count -eq 2) {
                        # Digit 6 found
                        Write-Host "6 Found"
                        $SixSegments = $setArray -join ""
                        continue
                    }
                    else {
                        $Matches = Compare-Object -ReferenceObject $setArray -DifferenceObject $FourSegments -IncludeEqual | Where-Object {$_.SideIndicator -eq "=="}
                        if ($Matches.Count -eq 3) {
                            # Digit 0 found
                            Write-Host "0 Found"
                            $ZeroSegments = $setArray -join ""
                            continue
                        }
                        else {
                            # Last 6 segment digit is 9
                            Write-Host "9 Found"
                            $NineSegments = $setArray -join ""
                            continue
                        }
                    }
                    
                }
            }
            5 {
                foreach ($set in $item.Group) {
                    $setArray = $set.ToCharArray() | Sort-Object
                    $Matches = Compare-Object -ReferenceObject $setArray -DifferenceObject $SevenSegments -IncludeEqual | Where-Object {$_.SideIndicator -eq "=="}
                    if ($Matches.Count -eq 3) {
                        # Digit 3 found
                        Write-Host "3 Found"
                        $ThreeSegments = $setArray -join ""
                        continue
                    }
                    else {
                        $Matches = Compare-Object -ReferenceObject $setArray -DifferenceObject $FourSegments -IncludeEqual | Where-Object {$_.SideIndicator -eq "=="}
                        if ($Matches.Count -eq 2) {
                            # Digit 2 found
                            Write-Host "2 Found"
                            $TwoSegments = $setArray -join ""
                            continue
                        }
                        else {
                            # Last 5 segment digit is 5
                            Write-Host "5 Found"
                            $FiveSegments = $setArray -join ""
                            continue
                        }
                    }
                    
                }
            }
        }
    }

    $FourSegments = $FourSegments -join ""
    $SevenSegments = $SevenSegments -join ""

    $DisplayOutput = ""
    foreach ($digit in $line.Output -split " ") {
        switch (($digit.ToCharArray() | Sort-Object) -join "") {
            $OneSegments {
                $DisplayOutput += "1"
            }
            $TwoSegments {
                $DisplayOutput += "2"
            }
            $ThreeSegments {
                $DisplayOutput += "3"
            }
            $FourSegments {
                $DisplayOutput += "4"
            }
            $FiveSegments {
                $DisplayOutput += "5"
            }
            $SixSegments {
                $DisplayOutput += "6"
            }
            $SevenSegments {
                $DisplayOutput += "7"
            }
            $EightSegments {
                $DisplayOutput += "8"
            }
            $NineSegments {
                $DisplayOutput += "9"
            }
            $ZeroSegments {
                $DisplayOutput += "0"
            }
        }
    }
    $result = $result + [int]$DisplayOutput

}

$result