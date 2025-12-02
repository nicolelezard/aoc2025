[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'

# $rawInput = Get-Content $PSScriptRoot\example.txt
$rawInput = Get-Content $PSScriptRoot\input.txt

<# Find the invalid IDs by looking for any ID which is made only of some sequence of digits repeated twice.
   So, 55 (5 twice), 6464 (64 twice), and 123123 (123 twice) would all be invalid IDs. #>

$rangeStrings = $rawInput -split ','

[hashtable[]]$ranges = $rangeStrings | % { $split = $_ -split '-'; @{ Bottom=[int64]$split[0]; Top=[int64]$split[1] } }

$rangeCounter = 0
$rangeCount = $ranges.Count
[string[]]$invalidIds = foreach ($range in $ranges) {
    $rangeCounter++

    Write-Progress -Id 1 -Activity "Ranges" -Status "[$rangeCounter/$rangeCount] $($range.Bottom) - $($range.Top)" -PercentComplete ([Math]::Floor(($rangeCounter/$rangeCount)*100))
    
    $numbersCounter = 0
    :numbers for ([int64]$num = $range.Bottom; $num -le $range.Top; $num++) {
        $number = $num.ToString()
        $len = $number.Length
        
        if ($len -lt 2) { continue numbers }
        
        $numbersCounter++
        if(0 -eq $numbersCounter % 1000) {
            Write-Progress -Id 2 -Activity "Numbers" -Status "[$num/$($range.Top)] $num" -PercentComplete ([Math]::Floor((($num - $range.Bottom)/($range.Top - $range.Bottom))*100))
        }

        :divisors for ($i = 1; $i -lt $len; $i++) {
            [int]$r = 0
            [int]$q = [Math]::DivRem($len, $i, [ref]$r)
            if (0 -ne $r) { continue divisors }

            [bool]$isInvalid = $number -match "($($number.Substring(0,$i))){$q}"

            if ($isInvalid)
            {
                Write-Debug "$number is invalid (len:$len, i:$i, q:$q, r:$r)"
                $number
                continue numbers
            }
        }
    }
}

$sum = $invalidIds | % {[int64]$_} | Measure-Object -Sum | Select-Object -ExpandProperty Sum

"The sum is $sum"

# look at the length. try to split it in different ways
        # $len = $number.ToString().Length

        # if ($len -lt 1) { continue numbers }

        # 