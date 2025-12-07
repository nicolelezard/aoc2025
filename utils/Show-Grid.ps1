
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