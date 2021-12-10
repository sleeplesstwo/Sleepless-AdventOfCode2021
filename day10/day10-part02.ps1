$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$ChunkData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$ChunkOpeners = @("(","[","{","<")
$ChunkClosers = @(")","]","}",">")

[System.Collections.ArrayList]$IllegalCharacters = @()
[System.Collections.ArrayList]$CompletionString = @()

:lineCheck foreach($line in $ChunkData) {
    $lineArray = $line.toCharArray()
    [System.Collections.ArrayList]$OpenedChunks = @()
    [System.Collections.ArrayList]$IncompleteLines = @()

    foreach ($character in $lineArray) {
        if("$character" -in $ChunkOpeners) {
            $OpenedChunks.Add($character) | Out-Null
        }
        elseif("$character" -in $ChunkClosers) {
            $OpenerIndex = $ChunkOpeners.IndexOf("$($OpenedChunks[-1])")
            $CorrectCloser = $ChunkClosers[$OpenerIndex]
            if ("$character" -ne $CorrectCloser) {
                Write-Host "Invalid character: Expected $($CorrectCloser) but found $character"
                $IllegalCharacters.Add($character) | Out-Null
                continue lineCheck
            }
            else {
                $OpenedChunks.RemoveAt(($OpenedChunks.Count - 1))
            }
        }
    }
    $OpenedChunks.Reverse()
    [System.Collections.ArrayList]$FinishedClosers = @()

    foreach ($character in $OpenedChunks) {
        $OpenerIndex = $ChunkOpeners.IndexOf("$character")
        $CorrectCloser = $ChunkClosers[$OpenerIndex]
        $FinishedClosers.Add($CorrectCloser) | Out-Null
    }
    $CompletionString.Add($FinishedClosers -join "") | Out-Null
}

[System.Collections.ArrayList]$results = @()

foreach ($item in $CompletionString) {
    $CompletionScore = 0
    foreach($character in $item.toCharArray()) {
        $CompletionScore = $CompletionScore * 5
        switch ($character) {
            ")" { $CompletionScore = $CompletionScore + 1}
            "]" { $CompletionScore = $CompletionScore + 2}
            "}" { $CompletionScore = $CompletionScore + 3}
            ">" { $CompletionScore = $CompletionScore + 4}
        }
    }
    $results.Add($CompletionScore) | Out-Null
}
$results = $results | Sort-Object
$result = $results[[math]::Floor($results.count/2)]
$result
$result | Set-Clipboard