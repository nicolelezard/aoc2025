[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'
. $PSScriptRoot\..\utils\grids.ps1

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# The forklifts can only access a roll of paper if there are fewer than four rolls of paper in the eight adjacent positions. 
Once a roll of paper can be accessed by a forklift, it can be removed.
Once a roll of paper is removed, the forklifts might be able to access more rolls of paper, which they might also be able to remove.
How many total rolls of paper could the Elves remove if they keep repeating this process? #>

$grid = $null

"Parsing input took " + (Measure-Command {
    $grid = ,$rawInput | Read-AsGrid -of {
        @{
            IsRoll = ('@' -eq $_)
            Value = $_
        }
    }
} | Select-Object -Expand TotalSeconds) + " seconds" | Out-Host

$grids = [System.Collections.Generic.Dictionary[int,hashtable[,]]]::new()

$n = 0
$grids[0] = $grid

$totalRemoved = $(
    do {
        $n++
        "[$n] Removing accessible rolls took " + (Measure-Command {
            $nextGrid = ,$grids[($n-1)] | New-Grid -of {
                @{
                    Sum = ($sum = $(
                        if (-not $_.IsRoll) {
                            0
                        }
                        else {
                            ,$grids[($n-1)] | Get-NeighborCount -Y $_.Y -X $_.X -Filter {
                                $_.IsRoll ? 1 : 0
                            } -StopAt 4
                        }
                    ) | Measure-Object -Sum | Select-Object -ExpandProperty Sum)
                    WasRoll = $_.IsRoll
                    IsRoll = ($isRoll = $sum -ge 4)
                    Value = $isRoll ? '@' : '.'
                }
            } -Debug:$false
        } | Select-Object -Expand TotalSeconds) + " seconds" | Out-Host
        
        if ($DebugPreference){
            "" | Write-Debug
            "[$n] Sums" | Write-Debug
            ,$nextGrid | Show-Grid -of {
                $_.WasRoll ? $_.Sum : '.' 
            } -Debug:$false | Write-Debug
        }
        
        $accessible = $nextGrid.Where({$_.WasRoll -and -not $_.IsRoll}).Count
        $accessible

        if ($DebugPreference){
            "" | Write-Debug
            "[$n] Accessible rolls: $accessible" | Write-Debug
            ,$nextGrid | Show-Grid -of {
                $_.WasRoll -and -not $_.IsRoll ? 'A' : '.'
            } -Debug:$false | Write-Debug
        }

        $grids[$n] = $nextGrid
    } until (
        0 -eq $accessible
    )
) | Measure-Object -Sum | Select-Object -ExpandProperty Sum

$totalRemoved

"" | Out-Host
"Total amount of removed rolls: $totalRemoved" | Out-Host