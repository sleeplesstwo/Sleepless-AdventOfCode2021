$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$input = Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")

$hpos = 0
$vpos = 0
$aim = 0

foreach ($line in $input) {
    $lineArray = $line -split " "
    $direction = $lineArray[0]
    $amount = $lineArray[1]
    switch ($direction) {
        "up" {
            $aim = $aim - $amount
        }
        "down" {
            $aim = $aim + $amount
        }
        "forward" {
            $hpos = $hpos + $amount
            $vpos = $vpos + ($aim * $amount)
        }
    }
}

$result = $hpos * $vpos
$result | Set-Clipboard