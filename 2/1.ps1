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

[string[]]$invalidIds = foreach ($range in $ranges) {

    # [string[]]$numbers = $range.Bottom..$range.Top | % {$_.ToString()}

    :numbers for ([int64]$num = $range.Bottom; $num -le $range.Top; $num++) {
        $number = $num.ToString()
        $len = $number.Length
        
        if (0 -ne $len % 2) { continue numbers }

        [string]$left = $number.Substring(0,$len/2)
        [string]$right = $number.SubString($len/2,$len/2)
        Write-Debug "$left - $right"

        if ($left -eq $right){
            $number
        }
    }
    # }
}

$sum = $invalidIds | % {[int64]$_} | Measure-Object -Sum | Select-Object -ExpandProperty Sum

"The sum is $sum"

# look at the length. try to split it in different ways
        # $len = $number.ToString().Length

        # if ($len -lt 1) { continue numbers }

        # $divisors = for ($i = 1; $i -le $len; $i++) {
        #     [Math]::DivRem($len, $i)
        # }