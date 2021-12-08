$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

#$SegmentData = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf" | ConvertFrom-CSV -Delimiter "|" -Header "Signal", "Output"
$SegmentData = Import-CSV -Path (Join-Path $BasePath -ChildPath "input.txt") -Delimiter "|" -Header "Signal","Output"

$OutputData = foreach ($line in $SegmentData) {
    $line.Signal, $line.Output -join ""
}
$result = 0

foreach ($line in $SegmentData) {
    #Group all the items in the signal by number of active segments
    $SortedLength = $line.Signal -split " " | Group-Object -Property Length

    # For every group of values of a specific length (number of lit segments)
    foreach ($item in $SortedLength) {
        # 4 cases are unique
        switch ($item.Name) {
            2 {
                # Digit 1 found never used for comparison so convert back to string with join
                $OneSegments = ($item.Group.ToCharArray() | Sort-Object) -join ""
                break
            }
            3 {
                # Digit 7 found
                $SevenSegments = ($item.Group.ToCharArray() | Sort-Object)
                break
            }
            4 {
                # Digit 4 found
                $FourSegments = ($item.Group.ToCharArray() | Sort-Object)
                break
            }
            7 {
                # Digit 8 found never used for comparison so convert back to string with join
                $EightSegments = ($item.Group.ToCharArray() | Sort-Object) -join ""
                break
            }
            6 {
                # Since this will have multiple results we need to itterate through them
                foreach ($set in $item.Group) {
                    
                    $setArray = $set.ToCharArray() | Sort-Object
                    # A 6 has exactly 2 identical lit segments as 7
                    $Matches = Compare-Object -ReferenceObject $setArray -DifferenceObject $SevenSegments -IncludeEqual | Where-Object {$_.SideIndicator -eq "=="}
                    if ($Matches.Count -eq 2) {
                        # Digit 6 found
                        Write-Host "6 Found"
                        $SixSegments = $setArray -join ""
                        continue
                    }
                    else {
                        # It's not a 6 so check to see if it has exactly 3 matching segments to a 4, which will match 0 otherwise it's a 9
                        $Matches = Compare-Object -ReferenceObject $setArray -DifferenceObject $FourSegments -IncludeEqual | Where-Object {$_.SideIndicator -eq "=="}
                        if ($Matches.Count -eq 3) {
                            # Digit 0 found
                            Write-Host "0 Found"
                            $ZeroSegments = $setArray -join ""
                            continue
                        }
                        else {
                            # Last 6 segment digit possible is 9
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
                    # Only 3 has 3 matching segments to 7 and 5 lit segments
                    $Matches = Compare-Object -ReferenceObject $setArray -DifferenceObject $SevenSegments -IncludeEqual | Where-Object {$_.SideIndicator -eq "=="}
                    if ($Matches.Count -eq 3) {
                        # Digit 3 found
                        Write-Host "3 Found"
                        $ThreeSegments = $setArray -join ""
                        continue
                    }
                    else {
                        # Since it wasn't 3 only 2 has 2 matching segments and 5 lit segments
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

    # Done with comparisons now so convert the 4 and 7 back to a string with join
    $FourSegments = $FourSegments -join ""
    $SevenSegments = $SevenSegments -join ""

    $DisplayOutput = ""
    foreach ($digit in $line.Output -split " ") {
        # Take the active segment and sort them alphabetically then compare against known values
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

    # Cast resulting string as an int and add it to the result
    $result = $result + [int]$DisplayOutput

}

$result