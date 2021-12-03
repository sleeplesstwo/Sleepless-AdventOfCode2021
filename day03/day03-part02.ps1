$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$inputdata = Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")

# Initialize an empty array.
$BitArray = @()

#Generate Array of objects representing bits
foreach ($line in $inputdata) {
    $BitValue = [PSCustomObject]@{
        '1' = $line[0]
        '2' = $line[1]
        '3' = $line[2]
        '4' = $line[3]
        '5' = $line[4]
        '6' = $line[5]
        '7' = $line[6]
        '8' = $line[7]
        '9' = $line[8]
        '10' = $line[9]
        '11' = $line[10]
        '12' = $line[11]
    }
    # Slow but works.  Probably should have just used an arraylist instead.
    $BitArray += $BitValue
}
$OxygenArray = $BitArray

#Loop through checking each of the 12 properties (bits)
for ($i = 1; $i -le 12; $i++) {
    # Break from loop if there is only 1 result left
    if ($OxygenArray.Count -eq 1) {
        break
    }
    # Group all objects by the current bit and sort descending by the count of each
    $Values = $OxygenArray | Group-Object -Property "$i" | Sort-Object -Property "Count" -Descending
    
    # If the coutns are equal then the values to keep should be 1
    if ($Values[0].Count -eq $Values[1].Count) {
        $CommonValue = 1
    }
    else {
        #Otherwise grab the value from the top value
        $CommonValue = $Values[0].Name
    }
    # Filter array values to return only entries where the current property being checked is valid
    $OxygenArray = $OxygenArray | Where-Object {$_."$i" -eq "$CommonValue"}
}

# Initialize Oxygen result as an empty string.
$OxygenResultBinary = ""

for ($i = 1; $i -le 12; $i++) {
    #For each property add the value of the property to the end of the string
    $OxygenResultBinary = [string]$OxygenResultBinary + [string]$OxygenArray."$i"
}

# Treat the string as a binary and convert to an int.  LOL Powershell types go brrrrrrrrrrrrrrrrrrr
$OxygenResultDecimal = [Convert]::ToInt32($OxygenResultBinary,2)

$CO2Array = $BitArray
for ($i = 1; $i -le 12; $i++) {
    # Break from loop if there is only 1 result left
    if ($CO2Array.Count -eq 1) {
        break
    }

    # Group all objects by the current bit and sort descending by the count of each
    $Values = $CO2Array | Group-Object -Property "$i" | Sort-Object -Property "Count" -Descending

    # If counts are equal then the value to keep should be 0
    if ($Values[0].Count -eq $Values[1].Count) {
        $CommonValue = 0
    }
    else {
        # Otherwise grab the value from the second (least) value
        $CommonValue = $Values[1].Name
    }
    # Filter array values to return only entries where the current property being checked is valid
    $CO2Array = $CO2Array | Where-Object {$_."$i" -eq "$CommonValue"}
}

# Initialize CO2 result as empty string
$CO2ResultBinary = ""
for ($i = 1; $i -le 12; $i++) {
    #For each property add the value of the property to the end of the string
    $CO2ResultBinary = [string]$CO2ResultBinary + [string]$CO2Array."$i"
}

#Powershell types go brrrrrrrrrrrrrrrr
$CO2ResultDecimal = [Convert]::ToInt32($CO2ResultBinary,2)

# Multiply results
$Result = $OxygenResultDecimal * $CO2ResultDecimal

# Set the clipboard to paste answer
$Result | Set-Clipboard