$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$input = Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")

#Initialize variables for calculations
$hpos = 0
$vpos = 0

foreach ($line in $input) {
    #Split the line into an array on space characters
    $lineArray = $line -split " "

    #Grab each value from the array.
    $direction = $lineArray[0]
    $amount = $lineArray[1]

    #Check direction and perform relevant calculation
    switch ($direction) {
        "up" {
            $vpos = $vpos - $amount
        }
        "down" {
            $vpos = $vpos + $amount
        }
        "forward" {
            $hpos = $hpos + $amount
        }
    }
}

# Multiply for final results and set the clipboard for pasting the answer.
$result = $hpos * $vpos
$result | Set-Clipboard