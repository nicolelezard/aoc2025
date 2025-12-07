[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'

$rawInput = Get-Content $PSScriptRoot\example.txt
# $rawInput = Get-Content $PSScriptRoot\input.txt

<# The forklifts can only access a roll of paper if there are fewer than four rolls of paper in the eight adjacent positions. 
How many rolls of paper can be accessed by a forklift? #>

