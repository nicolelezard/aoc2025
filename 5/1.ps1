[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'
. $PSScriptRoot\..\utils\grid.ps1

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# The fresh ID ranges are inclusive: the range 3-5 means that ingredient IDs 3, 4, and 5 are all fresh.
The ranges can also overlap; an ingredient ID is fresh if it is in any range.

How many of the available ingredient IDs are fresh? #>
$freshRangeSection = ($rawInput | Select-String -Pattern "^[0-9]+-[0-9]+$").Matches.Value
$availableSection = ($rawInput | Select-String -Pattern "^[0-9]+$").Matches.Value

$freshRanges = $freshRangeSection | ForEach-Object {
    $split = $_ -split '-'
    @{
        Start = ($start = [int64]$split[0])
        End = ($end = [int64]$split[1])
        Span = $end - $start 
    }
}

$available = $availableSection | ForEach-Object { [int64]$_ }
$sortedFreshRanges = $freshRanges | Sort-Object -Descending Span

$freshCounter = 0
$ingredientCounter = 0
$ingredientCount = $available.Count

$rangeCount = $sortedFreshRanges.Count
:ingredients foreach ($ingredient in $available) {
    $ingredientCounter++

    Write-Progress -Id 0 -Activity "Ingredients" -Status "[$ingredientCounter/$ingredientCount] $ingredient" -PercentComplete ([Math]::Floor(($ingredientCounter/$ingredientCount)*100))

    $rangeCounter = 0
    foreach ($range in $sortedFreshRanges) {
        $rangeCounter++

        if(0 -eq $rangeCounter % 1000) {
            Write-Progress -Id 1 -Activity "Ranges" -Status "[$rangeCounter/$rangeCount] $($range.Start) - $($range.End)" -PercentComplete ([Math]::Floor(($rangeCounter/$rangeCount)*100))
        }
            
        if ($ingredient -ge $range.Start -and $ingredient -le $range.End) {
            $freshCounter++
            continue ingredients
        }
    }
}

"Fresh ingredient count: $freshCounter"
