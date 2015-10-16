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

"@

<#
.SYNOPSIS

Writes on screen help message.
#>
function Write-Help
{
    Write-Output $helpStr
}

<#
.SYNOPSIS

Script entry point.
#>
function Process-Arguments($args)
{
    if (($args.Count -eq 0) -or (($arg[0] -eq "-h") -or ($arg[0] -eq "--help") -or ($arg[0] -eq "/?")))
    {
        Write-Help
        exit
    }
}

# Execute Entry Point and start program
Process-Arguments $args