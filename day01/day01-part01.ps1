$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

#Pull values from input file.
$measurements = Get-Content -Path (Join-Path $BasePath -ChildPath "day01-part01-input.txt")

#Initialize variables.
$increases = 0
$isFirstValue = $true

#Check each value against the previous, exclude the first value from checking.
foreach ($value in $measurements) {
    if ($isFirstValue) {
        $isFirstValue = $false
    }
    else {
        if ([int]$value -gt [int]$previousValue) {
            $increases++
        }
    }
    [int]$previousValue = [int]$value
}

# Set the clipboard with the value to paste into the answer.
$increases | Set-Clipboard