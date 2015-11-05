# Clown Car Powershell + Files -> Batch Script Self Extractor
# Command line interface
# By: Christian Gunderman

$helpStr = @"
Clown Car Powershell + Files -> Batch Script Self Extractor
Command line interface
By: Christian Gunderman

Clown Car is a series of hacky scripts that embed Powershell script(s)
and other files into a single batch script. You can then write Powershell
code that will run and, using an API, extract or invoke embedded files at
your will.

Usage: clown-car [out_batch_file] [entry_point_script] [files...]

"@

# Import the packager API.
Import-Module ".\resources\clown-car-packager-api.psm1"

<#
.SYNOPSIS

Writes on screen help message.
#>
function Write-Help
{
    Write-Output $helpStr
}

if ($args.Count -gt 1)
{
    Write-Output "Building self extractor..."
    Write-ClownCar $args[0] $args[1] (($args | Select -Skip 2) | Get-Item)
    Write-Output "Done"
    exit
}

Write-Help
exit