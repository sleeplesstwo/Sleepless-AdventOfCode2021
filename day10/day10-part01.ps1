$BasePath = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$ChunkData = (Get-Content -Path (Join-Path $BasePath -ChildPath "input.txt"))

$ChunkOpeners = @("(","[","{","<")
$ChunkClosers = @(")","]","}",">")

[System.Collections.ArrayList]$IllegalCharacters = @()

:lineCheck foreach($line in $ChunkData) {
    $lineArray = $line.toCharArray()
    [System.Collections.ArrayList]$OpenedChunks = @()

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

}

$SyntaxErrorScore = 0
foreach($character in $IllegalCharacters) {
    switch($character) {
        ")" { $SyntaxErrorScore = $SyntaxErrorScore + 3 }
        "]" { $SyntaxErrorScore = $SyntaxErrorScore + 57 }
        "}" { $SyntaxErrorScore = $SyntaxErrorScore + 1197 }
        ">" { $SyntaxErrorScore = $SyntaxErrorScore + 25137 }
    }
}

$SyntaxErrorScore
$SyntaxErrorScore | Set-Clipboard