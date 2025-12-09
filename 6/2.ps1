[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'
. $PSScriptRoot\..\utils\grid.ps1

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# Cephalopod math is written right-to-left in columns.
Each number is given in its own column, with the most significant digit at the top and the least significant digit at the bottom.
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

# use the last line to know how wide the column is
$operatorsH = $rawInput[-1] | Read-All "[\*\+] +"
$nColumns = $operatorsH.Count
for ($j = 0; $j -lt $nColumns; $j++) {

    $start = ($j -eq 0) ? 0 : $problems[($j-1)].XEnd + 2
    $width = ($j -eq $nColumns -1) ? $operatorsH[$j].Length : $operatorsH[$j].Length-1  # (trailing space separating columns, except on the last problem.)

    # initialize
    $problems[$j] = [PSCustomObject]@{
        Terms = [int[]]::new($width)
        Operator = $operatorsH[$j] -replace ' ', ''
        Width = $width
        XStart = $start
        XEnd = $start + $width -1
    }
}


$grid = ,$rawInput | Read-AsGrid -of {
    @{
        Value = $_
    }
}

# populate all problem terms

# for each problem,
$problems.Keys | ForEach-Object {
    $problem = $problems[$_]
    
    # read the numbers or empty chars from the grid
    for ($x = $problem.XEnd; $x -ge $problem.XStart; $x--) {
        $term = ($(for ($y = 0; $y -lt $nTerms; $y++) {
            $val = $grid[$y,$x].Value
            if (' ' -ne $val) {
                $val
            }
        }) -join '')

        $problem.Terms[($problem.XEnd - $x)] = $term
    }
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