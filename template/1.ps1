[CmdletBinding()]
param (
)

$ErrorActionPreference = 'Stop'
. $PSScriptRoot\..\utils\*.ps1

$rawInput = Get-Content $PSScriptRoot\example.txt
# $rawInput = Get-Content $PSScriptRoot\input.txt