[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $day
)

Copy-Item -Recurse template $day