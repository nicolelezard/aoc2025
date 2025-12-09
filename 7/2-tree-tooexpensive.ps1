[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Break'
. $PSScriptRoot\..\utils\grid.ps1
. $PSScriptRoot\..\utils\tree.ps1

$rawInput = Get-Content $PSScriptRoot\example.txt
# $rawInput = Get-Content $PSScriptRoot\input.txt

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
        Nodes = [List[Node]] (('S' -eq $_) ? $($list = [List[Node]]::new(); [void]$list.Add([Tree]::new()); $list) : [List[Node]]::new())
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
    
    $yBound = $f.GetUpperBound(0)
    $xBound = $f.GetUpperBound(1)
    $g = [hashtable[,]]::new($yBound +1, $xBound +1)
    [hashtable[,]]::Copy($f, 0, $g, 0, $f.Count)
    
    [Node]$handle = $null
    :y for ($y = 0; $y -lt $yBound; $y++) {

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
                        foreach ($node in $pos.Nodes) {
                            [void]$left.Nodes.Add($node.AddChild())
                            [void]$right.Nodes.Add($node.AddChild())
                        }
                    }
                    else {
                        # draw a beam under it, carry on the same timeline
                        $next.IsBeam = $true
                        $next.Value = '|'
                        [void]$next.Nodes.AddRange($pos.Nodes)
                        
                        $handle = $pos.Nodes[0]
                    }
                }
            }
        } | Select-Object -Expand TotalSeconds
        Write-Progress -Id 0 -Activity "Line" -Status "[$y/$yBound] - took $elapsed s to process" -PercentComplete $([Math]::Floor(($y/$yBound)*100))

        # $timelines = 0
        # $elapsed = Measure-Command {
        #     $timelines = $handle.GetRoot().CountLeaves()
        # } | Select-Object -Expand TotalMilliseconds

        # Write-Progress -Id 1 -Activity "Timelines" -Status "[$timelines] - took $elapsed ms to count"
    }

    Write-Output -NoEnumerate $g
    Write-Output $handle.GetRoot().CountLeaves()
}

$newGrid, $timelines = ,$grid | Split-TachyonRay

,$newGrid | Show-Grid -of {
    $_.Value
}

""
"The tachyon ray was split $timelines times"