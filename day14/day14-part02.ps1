$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$InsertionData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

[System.Collections.ArrayList]$Rules = @()
$Template = $InsertionData[0]
foreach ($rulestring in ($InsertionData[2..($InsertionData.Count - 1)])) {
    $Rule = $rulestring -split " -> "
    $Rule = [PSCustomObject]@{
        'Pair'   = $Rule[0]
        'Insert' = $Rule[1]
    }
    $Rules.Add($Rule) | Out-Null
}

# Not going to brute force this without a stupid amount of memory and time so starting over
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

    # Need this because of the way we will calculate the character count based off the pairs
    $LastCharacter = $Template[-1]

    # Create a hash table of all the rules which is all unique pairs
    $PairCountBase = @{}
    foreach ($rule in $Rules.Pair) {
        $PairCountBase.Add($rule, 0)
    }

    # Make a copy of the hash table and for every pair value in the initial template by 1
    $PairCount = $PairCountBase.Clone()
    for ($i = 0; $i -lt $Template.Length - 1; $i++) {
        $PairCount[($Template[$i] + $Template[($i + 1)])]++
    }

    # Compute each pass
    for ($i = 0; $i -lt $Pass; $i++) {
        Write-Progress -Activity "Computing pairs" -PercentComplete ($i / $Pass * 100) -Status "Pass $i of $Pass"
        # Clone a new empty hash table from our base
        $NewPairCount = $PairCountBase.Clone()

        # For every pair in our old hash table
        foreach ($UniquePair in $PairCount.Keys) {
            # If the value is 0 don't even bother calculating (saves trivial amount of time)
            if ($PairCount[$UniquePair] -ne 0) {
                # Check the rules object for the UniquePair to find the character to insert
                $InsertChar = $Rules | Where-Object { $_.Pair -eq $UniquePair }

                #Create the two new pairs and add them both to the count of pairs
                $FirstPair = $UniquePair[0] + $InsertChar.Insert
                $SecondPair = $InsertChar.Insert + $UniquePair[1]
                $NewPairCount["$FirstPair"] += $PairCount[$UniquePair]
                $NewPairCount["$SecondPair"] += $PairCount[$UniquePair]
            }
        }
        $PairCount = $NewPairCount
    }
    Write-Progress -Activity "Computing pairs" -Completed

    # Create a hash table to track the count of characters
    $totalChars = @{}

    # Go through all the keys and increment the character count based off the first character of each pair
    foreach ($UniquePair in $PairCount.Keys) {
        $totalChars[$UniquePair[0]] += $PairCount[$UniquePair]
    }
    
    # Because only the first character is used for counting we need to increment the value for the last character
    $totalChars[$LastCharacter]++

    return $totalChars
}

# Run through the passes and get the maximum and minimum values (counts of letters)
$measuredResult = (Get-PolymerResults -Rules $Rules -Template $Template -Pass 40).Values | Measure-Object -Maximum -Minimum
$result = $MeasuredResult.Maximum - $MeasuredResult.Minimum
$result