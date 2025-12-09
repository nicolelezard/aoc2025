[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'
. $PSScriptRoot\..\utils\grid.ps1

$rawInput = Get-Content $PSScriptRoot\example.txt
# $rawInput = Get-Content $PSScriptRoot\input.txt

<# The fresh ID ranges are inclusive: the range 3-5 means that ingredient IDs 3, 4, and 5 are all fresh.
The ranges can also overlap; an ingredient ID is fresh if it is in any range.

The Elves would like to know all of the IDs that the fresh ingredient ID ranges consider to be fresh. #>

$freshRangeSection = ($rawInput | Select-String -Pattern "^[0-9]+-[0-9]+$").Matches.Value

$freshRanges = $freshRangeSection | ForEach-Object {
    $split = $_ -split '-'
    @{
        Start = ($start = [int64]$split[0])
        End = ($end = [int64]$split[1])
        Span = $end - $start
        Absorbed = $false
    }
}

$sortedFreshRanges = $freshRanges | Sort-Object -Descending Span
$rangeCount = $sortedFreshRanges.Count

# for each range, starting with the smallest one and going up
:smallRanges for ($i = $sortedFreshRanges.Count-1; $i -ge 1; $i--) {
    
    $smallRange = $sortedFreshRanges[$i]
    
    # check for overlap with the bigger ones (starting with the biggest one)
    :bigRanges for ($j = 0; $j -lt $sortedFreshRanges.Count; $j++) {

        # (don't check against the one you're looking at)
        if ($j -eq $i){
            continue bigRanges
        }

        $bigRange = $sortedFreshRanges[$j]

        # (don't check against ones that have been absorbed)
        if ($bigRange.Absorbed){
            continue bigRanges
        }
        
        # check for overlap
        # b-----b
        #   s---s
        # 
        #  b--------b
        # s---s or s---s
        # 
        # b-----b
        #       s---s
        # 
        # b-----b
        #           s---s

        $smallStartsAfterBigStarts = $smallRange.Start -ge $bigRange.Start
        $smallStartsBeforeBigEnds = $smallRange.Start -le $bigRange.End
        $smallEndsAfterBigStarts = $smallRange.End -ge $bigRange.Start
        $smallEndsBeforeBigEnds = $smallRange.End -le $bigRange.End
        
        if ($smallStartsAfterBigStarts -and $smallStartsBeforeBigEnds) {
            # there is at least partial overlap on the left side

            if ($smallEndsBeforeBigEnds) {
                # complete overlap.
                $smallRange.Absorbed = $true
            }
            else {
                # merge
                $bigRange.End = $smallRange.End
                $bigRange.Span = $bigRange.End - $bigRange.Start
                $smallRange.Absorbed = $true
            }

            continue smallRanges
        }
        
        if ($smallEndsAfterBigStarts -and $smallEndsBeforeBigEnds) {
            # there is at least partial overlap on the right side

            if ($smallStartsAfterBigStarts) {
                # complete overlap.
                $smallRange.Absorbed = $true
            }
            else {
                # merge
                $bigRange.Start = $smallRange.Start
                $bigRange.Span = $bigRange.End - $bigRange.Start
                $smallRange.Absorbed = $true
            }

            continue smallRanges
        }
    }
}

# Then, using those consolidated ranges, count how many items they contain.
$consolidatedRanges = $sortedFreshRanges.Where({-not $_.Absorbed})

$freshCounter = 0
foreach ($range in $consolidatedRanges) {
    $freshCounter += $range.Span + 1
}

"Fresh ingredient count: $freshCounter"