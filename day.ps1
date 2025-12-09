[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $day
)

Copy-Item -Recurse $PSScriptRoot\template $PSScriptRoot\$day