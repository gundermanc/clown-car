# Clown Car Powershell + Files -> Batch Script Self Extractor
# Application Entry Point
# By: Christian Gunderman

<#
.SYNOPSIS

Your code goes here in this file. This function is the ClownCar application entry
point. From here you can call other functions or import additional files. Any files
in this directory will be ZIPPED up and embedded in the self extractor.
#>
function Main
{
    # Import any additional application modules here using Import-Module cmdlet
    # Make sure to get the path to the module like so:
    # Join-Path (Get-ClownCarDirectory) [your_file_name.psm1]

    $clownCarDir = Get-ClownCarDirectory
    $clownCarScript = Get-ClownCarScriptName
    $clownCarArguments = Get-ClownCarArguments
    $clownCarZip = Get-ClownCarZipPath
    $clownCarMain = Get-ClownCarMainPath

    Write-Output "Hello World!"
    Write-Output "`n"
    Write-Output "This message is coming from within the Main module of the ClownCar."
    Write-Output "The ClownCar was extracted to: $clownCarDir" 
    Write-Output "The ClownCar self extractor script is: $clownCarScript"
    Write-Output "The ClownCar self extractor script received the following arguments $clownCarArguments" 
    Write-Output "The ClownCar ZIP that was extracted into the directory is: $clownCarZip"
    Write-Output "The ClownCar main module is located at: $clownCarMain"
    Write-Output "`n"
    Write-Output "By default, ClownCar will clean up the extracted directory when Main()"
    Write-Output "returns, but you can optionally clean it up manually with ClownCarCleanupAndExit()"
    Write-Output "For debugging purposes you can use ClownCarExitWithoutCleanup and ClownCar will"
    Write-Output "terminate immediately without deleting the extracted directory."
}