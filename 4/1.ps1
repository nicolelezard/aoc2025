[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'
. $PSScriptRoot\..\utils\grid.ps1

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# The forklifts can only access a roll of paper if there are fewer than four rolls of paper in the eight adjacent positions. 
How many rolls of paper can be accessed by a forklift? #>


$grid = ,$rawInput | Read-AsGrid -of {
    @{
        IsRoll = ('@' -eq $_)
        Value = $_
    }
}

# ,$grid | Show-Grid -of { $_.Value }

$sumsGrid = ,$grid | New-Grid -of {
    @{
        Sum = $(
            if (-not $_.IsRoll) {
                0
            }
            else {

                # previous and next line, inside grid bounds
                :y for ($dY = -1; $dY -le 1; $dY++) {                    
                    if(-not($_.Y + $dY -ge $grid.GetLowerBound(0) -and $_.Y + $dY -le $grid.GetUpperBound(0))){
                        Write-Debug "y: $($_.Y + $dY) out of bounds"
                        0
                        continue y
                    }
                    
                    # previous and next column, inside grid bounds
                    :x for ($dX = -1; $dX -le 1; $dX++) {
                        if(-not ($_.X + $dX -ge $grid.GetLowerBound(1) -and $_.X + $dX -le $grid.GetUpperBound(1))){
                            Write-Debug "x: $($_.X + $dX) out of bounds"
                            0
                            continue x
                        }
                        
                        # don't count the item itself
                        if (0 -eq $dX -and 0 -eq $dY) {
                            Write-Debug "y: $($_.Y + $dY), x: $($_.X + $dX) skipped"
                            0
                            continue x
                        }
                        
                        if ($grid[($_.Y + $dY), ($_.X + $dX)].IsRoll){
                            Write-Debug "y: $($_.Y + $dY), x: $($_.X + $dX) is a roll"
                            1
                        } else {
                            Write-Debug "y: $($_.Y + $dY), x: $($_.X + $dX) is not a roll"
                            0
                        } 
                    }
                }
            }
        ) | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        Value = $_.Value
        IsRoll = $_.IsRoll
    }
} 

""
"Sums"
,$sumsGrid | Show-Grid -of {
    $_.IsRoll ? $_.Sum : '.' 
}

""
"Accessible rolls"
Write-Output ""
,$sumsGrid | Show-Grid -of {
    $_.IsRoll -and $_.Sum -lt 4 ? 'A' : '.'
}

""
"Total amount of accessible rolls: " + $sumsGrid.Where({$_.IsRoll -and $_.Sum -lt 4}).Count