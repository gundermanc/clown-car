# Clown Car Powershell + Files -> Batch Script Self Extractor
# Command line interface
# By: Christian Gunderman

$helpStr = @"
Clown Car Powershell + Files -> Batch Script Self Extractor
Command line interface
By: Christian Gunderman

Clown Car is a series of hacky scripts that allow you to:
  1) Bypass the obnoxius security settings for Powershell that require
     code signing. It does this by embedding your script(s) into a batch
     file which is unrestricted and can bypass the scripting security
     requirements.
  2) Obfuscates your scripts by embedding them, base64 encoded, within
     the batch file.
  3) Allows you to package your script's assets into a single
     self-extracting script containing a ZIP archive with anything you
     want!
  4) Provides a nice and easy to use temporary directory for your script
     to play in that is automagically deleted when you return from your
     main function.
  5) Powershell is a very powerful tool! Since it integrates with .NET,
     you have full access to WPF and WinForms and can conceivably build
     a rich client or server application with UI and advanced features.
     Although this is not an ideal scenario, it does have the benefit
     of making it really easy to spin off a small tool or application
     without installing the Microsoft SDKs. Since Powershell is present
     on every computer, this is a HUGE win. ClownCar provides the
     means to package your app into one file.

Before use, make sure that you have a Main.psm1 file in your chosen
assets_dir with a Main() function. This is the entry point that the
ClownCar extractor will call.

Usage: clown-car [out_batch_file] [assets_dir]

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

if ($args.Count -eq 2)
{
    Write-Output "Building self extractor..."
    Write-ClownCar $args[0] $args[1]
    Write-Output "Done"
    exit
}

Write-Help
exit