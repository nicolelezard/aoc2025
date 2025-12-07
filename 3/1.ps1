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

foreach ($bank in $banks) {
    
    $highest1 = 0
    $index1 = 0
    for ($i = 0; $i -lt $bank.Length-1; $i++) {
        $comp = $bank[$i]
        if (9 -eq $comp -or $comp -gt $highest1) {
            $highest1 = $comp
            $index1 = $i
        }
    }

    $highest2 = $bank[$index1 + 1]
    $index2 = $index1 + 1
    for ($j = $index1 + 2; $j -lt $bank.Length; $j++) {
        $comp = $bank[$j]
        if (9 -eq $comp -or $comp -gt $highest2) {
            $highest2 = $comp
            $index2 = $j
        }
    }

    $joltage = [int]::Parse("$highest1$highest2")
    Write-Debug "$joltage for bank: $bank"

    $sum += $joltage
}

"Total joltage: $sum"