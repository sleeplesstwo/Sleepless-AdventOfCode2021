$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$input = Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt")

$hpos = 0
$vpos = 0

foreach ($line in $input) {
    $lineArray = $line -split " "
    $direction = $lineArray[0]
    $amount = $lineArray[1]
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

$result = $hpos * $vpos
$result | Set-Clipboard