[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# You remember from the training seminar that "method 0x434C49434B" means
you're actually supposed to count the number of times any click causes the dial to point at 0,
regardless of whether it happens during a rotation or at the end of one.

Be careful: if the dial were pointing at 50, a single rotation like R1000 would cause the dial to point at 0 ten times before returning back to 50! #>

$start = 50
$turns = $rawInput -replace 'L', '-' -replace 'R', '' | % { [int]$_ }

$current = $start
$hits = 0

Write-Debug "The dial starts by pointing at 50."
foreach ($turn in $turns) {

    $count = [Math]::Abs($turn)
    $sign = [Math]::Sign($turn)

    for ($i = 1; $i -le $count; $i++) {
        if (0 -ne $i){
            $current += $sign
            if (0 -eq $current % 100) {
                $hits++
            }
        }
    }
}

"The password is $hits"