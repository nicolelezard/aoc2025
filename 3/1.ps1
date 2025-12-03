[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'

$rawInput = Get-Content $PSScriptRoot\example.txt
# $rawInput = Get-Content $PSScriptRoot\input.txt