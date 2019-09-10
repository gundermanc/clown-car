# Clown Car Powershell + Files -> Batch Script Self Extractor
# Packager API
# By: Christian Gunderman

<#
.SYNOPSIS

Creates a ClownCar script and writes it to the given output file, taking sources
from the given source directory.

#>
function Write-ClownCar
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1)][string]$outFile,
        [Parameter(Mandatory=$true, Position=2)][string]$sourceDirectory,
        [Parameter(Mandatory=$false, Position=3)][bool]$hideWindow)

# Temporary ZIP archive name.
$tmpZipFileName = (Join-Path (Convert-Path .) "tmp.archive.zip")

# Generate argument to set whether or not to hide the Window.
if ($hideWindow)
{
    $hideWindowArg = "-WindowStyle Hidden"
}

# ** MAKE SURE THAT Skip param has the same number of lines as this block generates. **
$batchTemplate = @"
@echo off
cmd.exe /C powershell.exe $hideWindowArg -ExecutionPolicy Bypass -Command `"`$__CC__pkgrArgs = '%*'.Split(' '); `$__CC__scriptName = '%0'; (Get-Content('%0') | Select -Skip 3) -Join [Environment]::NewLine | Invoke-Expression`"
exit
"@

# ClownCar loader and API functions.
# ** Skip param above assumes that this will all be minified to a single line. **
# ** As such, any functions here must be on a single line. **
$loaderTemplate = @"
Write-Output "Preparing...Please wait...May take a while"

`$__CC__tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
New-Item -ItemType Directory -Path (`$__CC__tmpDir) -Force | Out-Null
`$__CC__zipPath = Join-Path `$__CC__tmpDir "tmp.archive.zip"
[System.IO.File]::WriteAllBytes(`$__CC__zipPath, [Convert]::FromBase64String((Get-Content `$__CC__scriptName | Select -Skip 4)))
Add-Type -Assembly System.IO.Compression.FileSystem -ErrorAction Stop
[System.IO.Compression.ZipFile]::ExtractToDirectory(`$__CC__zipPath, `$__CC__tmpDir)

function Get-ClownCarDirectory { return `$__CC__tmpDir }
function Get-ClownCarScriptName { return `$__CC__scriptName }
function Get-ClownCarArguments { return `$__CC__pkgrArgs }
function Get-ClownCarZipPath { return `$__CC__zipPath }
function Get-ClownCarMainPath { return `$__CC__mainPath }
function ClownCarCleanupAndExit { Remove-Item -Recurse -Force `$__CC__tmpDir; Exit }
function ClownCarExitWithoutCleanup { exit }

`$__CC__mainPath = Join-Path `$__CC__tmpDir "main.psm1"
Import-Module "`$__CC__mainPath"

Main

ClownCarCleanupAndExit
"@

    <#
    .SYNOPSIS

    Sets up the required bits of the ClownCar environment.

    #>
    function Add-Environment
    {
        Trap
        {
            Write-Output "Unable to load System.IO.Compression .NET assembly."
            Break
        }

        Add-Type -Assembly System.IO.Compression.FileSystem -ErrorAction Stop
    }

    <#
    .SYNOPSIS

    Creates a ZIP archive with the name $zipArchivePath from the files
    and directories contained in $sourcePath.

    #>
    function Write-ZipArchiveFromDirectory($zipArchivePath, $sourcePath)
    {
        Trap
        {
            Write-Output "Unable to zip files"
            Break
        }

        try
        {
            $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
            [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcePath, $zipArchivePath, $compressionLevel, $false)
        }
        catch [System.IO.IOException], [UnauthorizedAccessException]
        {
            Write-Output "Unable to create zip archive: " $_.Exception.Message
            Break
        }
    }

    <#
    .SYNOPSIS

    Deletes the specified file, if it exists.

    #>
    function Remove-TemporaryFile($file)
    {
        Trap
        {
            Write-Output "Unable to delete " $file
            Break
        }

        if (Test-Path $file)
        {
            Remove-Item $file
        }
    }

    <#
    .SYNOPSIS

    Writes the batch file section of the output file. This section is the part that
    bypasses Powershell security settings and runs the Powershell Loader.

    #>
    function Write-BatchFileHeader($outFile)
    {
        Trap
        {
            Write-Output "Unable to write batch file header"
            Break
        }

        $batchTemplate | Out-File -FilePath $outFile -Encoding oem
    }

    <#
    .SYNOPSIS

    Writes the Powershell self-extractor and Main() loader portion of the output
    file.

    #>
    function Write-Loader($outFile)
    {
        Trap
        {
            Write-Output "Unable to write encoded loader portion"
            Break
        }

        $minifedLoaderTemplate = $loaderTemplate.Replace("`r", "").Replace("`n", ";")
        $minifedLoaderTemplate | Out-File -FilePath $outFile -Append -Encoding oem
    }

    <#
    .SYNOPSIS

    Writes the ZIP section of the ClownCar file.

    #>
    function Write-ZipClownCarSection($outFile)
    {
        Trap
        {
            Write-Output "Unable to write ClownCar ZIP section or read temporary ZIP archive"
            Break
        }

        $bytes = [System.IO.File]::ReadAllBytes($tmpZipFileName)

        [Convert]::ToBase64String($bytes) | Out-File -FilePath $outFile -Append -Encoding oem
    }
    
    # Error message if unable to proceed.
    Trap
    {
        Write-Output "Unable to produce ClownCar batch script"
        Break
    }


    # Load any needed dependencies.
    Add-Environment

    # Delete Temp file.
    Remove-TemporaryFile $tmpZipFileName

    # Create a ZIP archive.
    Write-Output "Creating ZIP archive..."
    Write-ZipArchiveFromDirectory $tmpZipFileName $sourceDirectory

    # Delete Windows Batch file.
    Remove-TemporaryFile $outFile

    # Write Batch file header.
    Write-Output "Writing Windows batch file header..."
    Write-BatchFileHeader $outFile

    # Powershell extractor and Main() loader.
    Write-Output "Writing Powershell ZIP self-extractor..."
    Write-Output "Writing Main() loader..."
    Write-Loader($outFile)

    # Reads in the temporary ZIP archive and dumps it in the batch file.
    Write-Output "Writing ZIPPED file section..."
    Write-ZipClownCarSection $outFile
}