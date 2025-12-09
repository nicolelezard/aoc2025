
function Read-AsGrid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$rawInput,
        [Parameter(Mandatory)]
        [pspropertyexpression]$of
    )

    $yBound = $rawInput.Count -1
    $xBound = $rawInput[0].Length -1

    $grid = [hashtable[,]]::new($yBound +1, $xBound +1)
    
    for ($y = 0; $y -le $yBound; $y++) {
        for ($x = 0; $x -le $xBound; $x++) {
            # desired props
            $grid[$y,$x] = $of.GetValues($rawInput[$y][$x])[0].Result
            
            # helpful indices
            $grid[$y,$x]["Y"] = $y
            $grid[$y,$x]["X"] = $x
        }
    }

    Write-Output -NoEnumerate $grid
}

function New-Grid {
    [CmdletBinding()]
    param (
        # 2D grid of objects (hastables)
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable[,]]$fromGrid,
        # Expression to apply to each object. Should return a hashtable
        [Parameter(Mandatory)]
        [pspropertyexpression]$of
    )

    $yBound = $fromGrid.GetUpperBound(0)
    $xBound = $fromGrid.GetUpperBound(1)

    $newGrid = [hashtable[,]]::new($yBound +1, $xBound +1)

    for ($y = 0; $y -le $yBound; $y++) {
        for ($x = 0; $x -le $xBound; $x++) {
            # apply the expression
            $newGrid[$y,$x] = $of.GetValues($fromGrid[$y,$x])[0].Result
            # helpful indices
            $newGrid[$y,$x]["Y"] = $y
            $newGrid[$y,$x]["X"] = $x
        }
    }

    Write-Output -NoEnumerate $newGrid
}

function Show-Grid {
    [CmdletBinding()]
    param (
        # 2D grid of objects (hastables)
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable[,]]$grid,
        # Expression to apply to each object. Should return strings of equal length.
        [Parameter(Mandatory)]
        [pspropertyexpression]$of
    )
    $yBound = $grid.GetUpperBound(0)
    $xBound = $grid.GetUpperBound(1)

    $row = [string[]]::new($xBound +1)

    for ($y = 0; $y -le $yBound; $y++) {

        for ($x = 0; $x -le $xBound; $x++) {

            # apply the expression
            $res = $of.GetValues($grid[$y,$x])[0].Result
            
            # update the line
            $row[$x] = $res
        }
        
        # display the line
        $row -join ' '
    }
}

function Get-NeighborCount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable[,]]$grid,
        [Parameter(Mandatory)]
        [int]$y,
        [Parameter(Mandatory)]
        [int]$x,
        [Parameter(Mandatory)]
        [pspropertyexpression]$filter,
        # stop counting neighbors once the count reaches this value
        [Parameter()]
        [int]$stopAt
    )

    # previous and next line, inside grid bounds
    $count = 0
    :y for ($dY = -1; $dY -le 1; $dY++) {
        if(-not($y + $dY -ge $grid.GetLowerBound(0) -and $y + $dY -le $grid.GetUpperBound(0))){
            Write-Debug "y: $($y + $dY) out of bounds"
            0
            continue y
        }
        
        # previous and next column, inside grid bounds
        :x for ($dX = -1; $dX -le 1; $dX++) {
            if(-not ($x + $dX -ge $grid.GetLowerBound(1) -and $x + $dX -le $grid.GetUpperBound(1))){
                Write-Debug "x: $($x + $dX) out of bounds"
                0
                continue x
            }
            
            # don't count the item itself
            if (0 -eq $dX -and 0 -eq $dY) {
                Write-Debug "y: $($y + $dY), x: $($x + $dX) skipped"
                0
                continue x
            }
            
            Write-Debug "y: $($y + $dY), x: $($x + $dX)"

            $res = $filter.GetValues($grid[($y + $dY),($x + $dX)])[0].Result
            $res
            $count += $res

            if ($stopAt -eq $count){
                break y
            }
        }
    }
}
