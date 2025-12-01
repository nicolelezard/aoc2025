[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# The actual password is the number of times the dial is left pointing at 0 after any rotation in the sequence.
Because the dial points at 0 a total of three times during this process, the password in this example is 3.
Analyze the rotations in your attached document. What's the actual password to open the door? #>

$start = 50
$turns = $rawInput -replace 'L', '-' -replace 'R', '' | % {[int]$_}

$current = $start
$hits = 0
foreach ($turn in $turns) {
    $current += $turn

    if ($current % 100 -eq 0) {
        $hits++
    }
}

"The password is $hits"