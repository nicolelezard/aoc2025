[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Break'
. $PSScriptRoot\..\utils\*.ps1

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

$grid = ,$rawInput | Read-AsGrid -of {
    @{
        Value = $_
        IsSplitter = '^' -eq $_
        IsBeam = 'S' -eq $_
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
    $splitCount = 0
    
    $yBound = $f.GetUpperBound(0)
    $xBound = $f.GetUpperBound(1)
    $g = [hashtable[,]]::new($yBound +1, $xBound +1)
    [hashtable[,]]::Copy($f, 0, $g, 0, $f.Count)
    
    :y for ($y = 0; $y -lt $yBound; $y++) {

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

                    $splitCount++
                }
                else {
                    # draw a beam under it
                    $next.IsBeam = $true
                    $next.Value = '|'
                }
            }
        }
    }

    Write-Output -NoEnumerate $g
    Write-Output $splitCount
}

$newGrid, $splitCount = ,$grid | Split-TachyonRay

,$newGrid | Show-Grid -of {
    $_.Value
}

""
"The tachyon ray was split $splitCount times"