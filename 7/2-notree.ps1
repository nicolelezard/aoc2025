[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Break'
. $PSScriptRoot\..\utils\grid.ps1
. $PSScriptRoot\..\utils\tree.ps1

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# With a quantum tachyon manifold, only a single tachyon particle is sent through the manifold.
A tachyon particle takes both the left and right path of each splitter encountered.

Each time a particle reaches a splitter, it's actually time itself which splits.
In one timeline, the particle went left, and in the other timeline, the particle went right.

To fix the manifold, what you really need to know is the number of timelines active after a single particle completes all of its possible journeys through the manifold. #>

<# I think this is just a binary tree, of which I want to count the leaf nodes. #>

$grid = ,$rawInput | Read-AsGrid -of {
    @{
        Value = $_
        IsSplitter = '^' -eq $_
        IsBeam = 'S' -eq $_
        Timelines = 'S' -eq $_ ? 1 : 0 
    }
}

function Split-TachyonRay {
    [CmdletBinding()]
    param (
        # 2D grid of objects (hastables)
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable[,]]$fromGrid
    )

    $f = $fromGrid
    $timelines = 0
    
    $yBound = $f.GetUpperBound(0)
    $xBound = $f.GetUpperBound(1)
    $g = [hashtable[,]]::new($yBound +1, $xBound +1)
    [hashtable[,]]::Copy($f, 0, $g, 0, $f.Count)
    
    :y for ($y = 0; $y -le $yBound; $y++) {

        if ($y -eq $yBound){
            # done. tally up
            $elapsed = Measure-Command {
                
                :x for ($x = 0; $x -le $xBound; $x++) {
                    $pos = $g[$y,$x]

                    if ($pos.IsBeam) {
                        $timelines += $pos.Timelines
                    }
                }
            } | Select-Object -Expand TotalMilliseconds
            Write-Progress -Id 1 -Activity "Timelines" -Status "[$timelines] - took $elapsed ms to count"
            break y
        }
            

        $elapsed  = Measure-Command {
            :x for ($x = 0; $x -le $xBound; $x++) {
                
                $pos = $g[$y,$x]
                
                if ($pos.IsSplitter) {
                    continue x
                }
                
                # find the rays
                if ($pos.IsBeam) {
                    
                    $next = $g[($y+1),$x]
                    
                    # will it hit a splitter?
                    if ($next.IsSplitter) {
                        # split the beam
                        $left = $g[($y+1),($x-1)]
                        $right = $g[($y+1),($x+1)]
                        
                        $left.IsBeam = $true
                        $left.Value = '|'
                        $right.IsBeam = $true
                        $right.Value = '|'
                        
                        # Create a split in the timeline
                        $left.Timelines += $pos.Timelines
                        $right.Timelines += $pos.Timelines
                    }
                    else {
                        # draw a beam under it, carry on the same timeline
                        $next.IsBeam = $true
                        $next.Value = '|'
                        $next.Timelines += $pos.Timelines
                    }
                }
            }
        } | Select-Object -Expand TotalSeconds
        Write-Progress -Id 0 -Activity "Line" -Status "[$y/$yBound] - took $elapsed s to process" -PercentComplete $([Math]::Floor(($y/$yBound)*100))
    }

    Write-Output -NoEnumerate $g
    Write-Output $timelines
}

$newGrid, $timelines = ,$grid | Split-TachyonRay

,$newGrid | Show-Grid -of {
    $_.Value
}

""
"The tachyon ray was split $timelines times"