$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$InsertionData = (Get-Content -Path (Join-Path $BasePath -ChildPath "testinput.txt"))
[System.Collections.ArrayList]$Rules = @()
$Template = $InsertionData[0]
foreach ($rulestring in ($InsertionData[2..($InsertionData.Count - 1)])) {
    $Rule = $rulestring -split " -> "
    $Rule = [PSCustomObject]@{
        'Pair' = $Rule[0]
        'Insert' = $Rule[1]
    }
    $Rules.Add($Rule) | Out-Null
}

function Get-PolymerResults {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object[]]
        $Rules,

        [Parameter()]
        [string]
        $Template,

        [Parameter()]
        [int]
        $Pass
    )

    for ($i=0;$i -lt $Pass;$i++) {
        Write-Progress -Id 0 -Activity "Calculating Polymer Chains" -PercentComplete (($i / $Pass) * 100) -Status "Pass $i of $Pass"
        $Polymer = $Template
        for ($j=0;$j -lt ($Polymer.length - 1);$j++) {
            Write-Progress -Id 1 -ParentId 0 -Activity "Pair Processing" -PercentComplete (($j / ($Polymer.length - 1)) * 100) -Status "$Pair $j of $($Polymer.length - 1)"
            $Pair = $Polymer[$j..($j+1)] -join ""
            if($j -eq 0) {
                $Template = $Polymer[$j] + ($Rules | Where-Object { $_.Pair -eq $Pair }).Insert + $Polymer[($j+1)]
            } elseif ($j -eq ($Polymer.Count - 2)) {
                $Template = $Template + ($Rules | Where-Object { $_.Pair -eq $Pair }).Insert + $Polymer[($j+1)]
            } else {
                $Template = $Template + ($Rules | Where-Object { $_.Pair -eq $Pair }).Insert + $Polymer[($j+1)]
            }
        }
        Write-Progress -Activity "Pair Processing" -Id 1 -Completed
    }
    Write-Progress -Activity "Calculating Polymer Chains" -Completed
    return $Template
}

$ResultGroup = (Get-PolymerResults -Rules $Rules -Template $Template -Pass 40).toCharArray() | Group-Object | Sort-Object -Property Count
#Get-PolymerResults -Rules $Rules -Template $Template -Pass 10
$result = ($ResultGroup[-1].Count) - ($ResultGroup[0].Count)
$result