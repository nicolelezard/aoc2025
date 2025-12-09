[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'
. $PSScriptRoot\..\utils\grid.ps1

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# Each problem's numbers are arranged vertically; at the bottom of the problem is the symbol for the operation that needs to be performed. Problems are separated by a full column of only spaces.  The left/right alignment of numbers within each problem can be ignored.

What is the grand total found by adding together all of the answers to the individual problems? #>

$problems = [System.Collections.Generic.Dictionary[int,PSCustomObject]]::new()

$nLines = $rawInput.Count
$nTerms = $nLines -1

function Read-All (
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$from,
    [Parameter(Mandatory,Position=0)]
    [string]$pattern
    ) {
    
    ($from | Select-String -Pattern $pattern -AllMatches).Matches.Value
}

# use the first line to initialize the problems
$termsH = $rawInput[0] | Read-All "[0-9]+"
$nColumns = $termsH.Count
for ($j = 0; $j -lt $nColumns; $j++) {
    $problems[$j] = [PSCustomObject]@{
        Terms = [int[]]::new($nTerms)
        Operator = $null
    }
    $problems[$j].Terms[0] = $termsH[$j]
}

# populate all problem terms
for ($i = 1; $i -lt $nTerms; $i++) {
    $termsH = $rawInput[$i] | Read-All "[0-9]+"

    for ($j = 0; $j -lt $nColumns; $j++) {
        $problems[$j].Terms[$i] = $termsH[$j]
    }
}

# use the last line to set the operator
$operatorsH = $rawInput[-1] | Read-All "[\*\+]"
for ($j = 0; $j -lt $nColumns; $j++) {
    $problems[$j].Operator = $operatorsH[$j]
}

# show the problems
if ($DebugPreference) {
    $problems.Keys | ForEach-Object {
        $problems[$_] | Write-Debug
    }
}

# run the numbers
$grandTotal = 0
$problems.Keys | ForEach-Object {
    $problem = $problems[$_]
    
    if ('*' -eq $problem.Operator) {
        $answer = 1
        $problem.Terms | ForEach-Object { $answer *= $_ }
    }
    elseif ('+' -eq $problem.Operator) {
        $answer = 0
        $problem.Terms | ForEach-Object { $answer += $_ }
    }

    $grandTotal += $answer
}

"Grand total is $grandTotal"