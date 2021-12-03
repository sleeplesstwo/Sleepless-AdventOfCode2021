$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

#$inputdata = Get-Content -Path (Join-Path $BasePath -ChildPath "testinput.txt")
$inputdata = Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")

$BitArray = @()

# Create an object of the bits.
foreach ($line in $inputdata) {
    $BitValue = [PSCustomObject]@{
        'First' = $line[0]
        'Second' = $line[1]
        'Third' = $line[2]
        'Fourth' = $line[3]
        'Fifth' = $line[4]
        'Sixth' = $line[5]
        'Seventh' = $line[6]
        'Eighth' = $line[7]
        'Nineth' = $line[8]
        'Tenth' = $line[9]
        'Eleventh' = $line[10]
        'Twelveth' = $line[11]
    }

    $BitArray += $BitValue
}

# It works but oh god why.  I should have just changed the property names to decimal numbers
$FirstBitResult = ($BitArray | Group-Object -Property "First" | Sort-Object -Property "Count" -Descending)[0].Name
$SecondBitResult = ($BitArray | Group-Object -Property "Second" | Sort-Object -Property "Count" -Descending)[0].Name
$ThirdBitResult = ($BitArray | Group-Object -Property "Third" | Sort-Object -Property "Count" -Descending)[0].Name
$FourthBitResult = ($BitArray | Group-Object -Property "Fourth" | Sort-Object -Property "Count" -Descending)[0].Name
$FifthBitResult = ($BitArray | Group-Object -Property "Fifth" | Sort-Object -Property "Count" -Descending)[0].Name
$SixthBitResult = ($BitArray | Group-Object -Property "Sixth" | Sort-Object -Property "Count" -Descending)[0].Name
$SeventhBitResult = ($BitArray | Group-Object -Property "Seventh" | Sort-Object -Property "Count" -Descending)[0].Name
$EighthBitResult = ($BitArray | Group-Object -Property "Eighth" | Sort-Object -Property "Count" -Descending)[0].Name
$NinethBitResult = ($BitArray | Group-Object -Property "Nineth" | Sort-Object -Property "Count" -Descending)[0].Name
$TenthBitResult = ($BitArray | Group-Object -Property "Tenth" | Sort-Object -Property "Count" -Descending)[0].Name
$EleventhBitResult = ($BitArray | Group-Object -Property "Eleventh" | Sort-Object -Property "Count" -Descending)[0].Name
$TwelvethBitResult = ($BitArray | Group-Object -Property "Twelveth" | Sort-Object -Property "Count" -Descending)[0].Name

# Join all the results into a single string.
$BinaryResultGamma = $FirstBitResult,$SecondBitResult,$ThirdBitResult,$FourthBitResult,$FifthBitResult,$SixthBitResult,$SeventhBitResult,$EighthBitResult,$NinethBitResult,$TenthBitResult,$EleventhBitResult,$TwelvethBitResult -join ""

# Treat the string as a binary value and convert that value to an int.
$GammaResult = [Convert]::ToInt32($BinaryResultGamma,2)

$FirstBitResult = ($BitArray | Group-Object -Property "First" | Sort-Object -Property "Count" -Descending)[1].Name
$SecondBitResult = ($BitArray | Group-Object -Property "Second" | Sort-Object -Property "Count" -Descending)[1].Name
$ThirdBitResult = ($BitArray | Group-Object -Property "Third" | Sort-Object -Property "Count" -Descending)[1].Name
$FourthBitResult = ($BitArray | Group-Object -Property "Fourth" | Sort-Object -Property "Count" -Descending)[1].Name
$FifthBitResult = ($BitArray | Group-Object -Property "Fifth" | Sort-Object -Property "Count" -Descending)[1].Name
$SixthBitResult = ($BitArray | Group-Object -Property "Sixth" | Sort-Object -Property "Count" -Descending)[1].Name
$SeventhBitResult = ($BitArray | Group-Object -Property "Seventh" | Sort-Object -Property "Count" -Descending)[1].Name
$EighthBitResult = ($BitArray | Group-Object -Property "Eighth" | Sort-Object -Property "Count" -Descending)[1].Name
$NinethBitResult = ($BitArray | Group-Object -Property "Nineth" | Sort-Object -Property "Count" -Descending)[1].Name
$TenthBitResult = ($BitArray | Group-Object -Property "Tenth" | Sort-Object -Property "Count" -Descending)[1].Name
$EleventhBitResult = ($BitArray | Group-Object -Property "Eleventh" | Sort-Object -Property "Count" -Descending)[1].Name
$TwelvethBitResult = ($BitArray | Group-Object -Property "Twelveth" | Sort-Object -Property "Count" -Descending)[1].Name

$BinaryResultEpsilon = $FirstBitResult,$SecondBitResult,$ThirdBitResult,$FourthBitResult,$FifthBitResult,$SixthBitResult,$SeventhBitResult,$EighthBitResult,$NinethBitResult,$TenthBitResult,$EleventhBitResult,$TwelvethBitResult -join ""

$EpsilonRate = [Convert]::ToInt32($BinaryResultEpsilon,2)

$Result = $GammaResult * $EpsilonRate

$Result | Set-Clipboard