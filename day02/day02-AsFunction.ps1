function Get-Day2Solution {
    [CmdletBinding()]
    param (
        #Input file to use for calculating solution.
        [Parameter(Mandatory=$true)]
        [string]
        $InputFile,

        # Calculate solution for which part?
        [Parameter()]
        [ValidateRange(1,2)]
        [int]
        $Part = 1
    )

    begin {
        #Import input file with space character as delimiter and initialize variables used for calculation
        $values = Import-CSV -Path $InputFile -Header "direction","amount" -Delimiter " "
        $hpos = 0
        $vpos = 0
        $aim = 0
    }

    process {
        foreach ($line in $values) {
            if ($Part -eq 1) {
                switch ($line.direction) {
                    "up" {
                        $vpos = $vpos - $line.amount
                    }
                    "down" {
                        $vpos = $vpos + $line.amount
                    }
                    "forward" {
                        $hpos = $hpos + $line.amount
                    }
                }
            }
            elseif ($Part -eq 2) {
                switch ($line.direction) {
                    "up" {
                        $aim = $aim - $line.amount
                    }
                    "down" {
                        $aim = $aim + $line.amount
                    }
                    "forward" {
                        $hpos = $hpos + $line.amount
                        $vpos = $vpos + ($aim * $line.amount)
                    }
                }
            }
        }  
    }

    end {
        $result = $hpos * $vpos
        return $result
    }
}

Get-Day2Solution -InputFile ".\input.txt" -Part 1
Get-Day2Solution -InputFile ".\input.txt" -Part 2