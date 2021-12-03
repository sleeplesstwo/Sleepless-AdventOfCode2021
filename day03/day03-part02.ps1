$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$inputdata = Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")

$BitArray = @()

#Generate Array of objects representing bits.
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

    $BitArray += $BitValue
}
$OxygenArray = $BitArray

for ($i = 1; $i -le 12; $i++) {
    if ($OxygenArray.Count -eq 1) {
        break
    }
    $Values = $OxygenArray | Group-Object -Property "$i" | Sort-Object -Property "Count" -Descending
    if ($Values[0].Count -eq $Values[1].Count) {
        $CommonValue = 1
    }
    else {
        $CommonValue = $Values[0].Name
    }
    $OxygenArray = $OxygenArray | Where-Object {$_."$i" -eq "$CommonValue"}
}


$OxygenResultBinary = ""
for ($i = 1; $i -le 12; $i++) {
    $OxygenResultBinary = [string]$OxygenResultBinary + [string]$OxygenArray."$i"
}

$OxygenResultDecimal = [Convert]::ToInt32($OxygenResultBinary,2)

$CO2Array = $BitArray
for ($i = 1; $i -le 12; $i++) {
    if ($CO2Array.Count -eq 1) {
        break
    }
    $Values = $CO2Array | Group-Object -Property "$i" | Sort-Object -Property "Count" -Descending
    if ($Values[0].Count -eq $Values[1].Count) {
        $CommonValue = 0
    }
    else {
        $CommonValue = $Values[1].Name
    }
    $CO2Array = $CO2Array | Where-Object {$_."$i" -eq "$CommonValue"}
}
$CO2ResultBinary = ""
for ($i = 1; $i -le 12; $i++) {
    $CO2ResultBinary = [string]$CO2ResultBinary + [string]$CO2Array."$i"
}

$CO2ResultDecimal = [Convert]::ToInt32($CO2ResultBinary,2)

$Result = $OxygenResultDecimal * $CO2ResultDecimal

$Result | Set-Clipboard