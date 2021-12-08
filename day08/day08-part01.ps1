$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$SegmentData = Import-CSV -Path (Join-Path $BasePath -ChildPath "input.txt") -Delimiter "|" -Header "Signal","Output"

$OutputData = $SegmentData.Output -split " "

$UniqueDigitCount = 0

foreach ($line in $OutputData) {
    if ($line.Length -in @(2,3,4,7)) {
        $UniqueDigitCount++
    }
}

$UniqueDigitCount