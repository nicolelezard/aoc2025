[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# if you have a bank like 12345 and you turn on batteries 2 and 4, the bank would produce 24 jolts. (You cannot rearrange batteries.) 
You'll need to find the largest possible joltage each bank can produce. #>

$banks = [string[]]$rawInput
$sum = 0

:banks foreach ($bank in $banks) {
    
    $batteries = @(0,0,0,0,0,0,0,0,0,0,0,0)

    $bIndex = -1
    :r for ($r = 0; $r -lt 12; $r++) {
        
        $highest = 0
        $hIndex = 0
        
        # to pick 12 batteries from a bank        of 15, the 1st should be at most the 4th.
        # to pick 12 batteries from a bank        of  n, the 1st should be at most the (n-12+1)th.
        # (...)
        # to pick 12-r batteries from the remaining (n-(12-r)), the 1st should be at most the (n-r+1)th.
        # 
        # (...)
        # to pick 1 battery from the remaining (n-(12-1)), the nth should be at most the nth.
        # to pick 1 battery from the    remaining  4, the   12th should be at most the 15th.
        $upperBound = $bank.Length-(12-$r)+1

        :j for ($j = $bIndex + 1; $j -lt $upperBound; $j++) {
            $comp = $bank[$j]
            if ($comp -gt $highest) {
                $highest = $comp
                $hIndex = $j

                if (9 -eq $comp) {
                    break j
                }
            }
        }

        $batteries[$r] = $highest
        $bIndex = $hIndex
    }

    $joltage = [int64]::Parse($batteries -join '')
    Write-Debug "$joltage for bank: $bank"

    $sum += $joltage
}

"Total joltage: $sum"