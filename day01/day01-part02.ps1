$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

#Pull values from input file.
$measurements = Get-Content -Path (Join-Path $BasePath -ChildPath "day01-part01-input.txt")

#Initialize values
$previousValue = $null
$value = $null
$increases = 0

#Loop for entire array minus 2 for the 3 value sliding window
for ($i = 0; ($i -lt ($measurements.Count - 2)); $i++ ) {
    if ($i -eq 0) {
        $value = $measurements[$i] + $measurements[$i+1] + $measurements[$i+2]
    } else {
        $value = $measurements[$i] + $measurements[$i+1] + $measurements[$i+2]
        if ($value -gt $previousValue) {
            $increases++
        }
    }
    $previousValue = $value
}

#Set Clipboard to results for pasting.
$increases | Set-Clipboard