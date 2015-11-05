# Clown Car Powershell + Files -> Batch Script Self Extractor
# Packager API
# By: Christian Gunderman

# Format template for the batch section of the archive that executes the powershell.
$batchTemplateFormat = @"
@echo off`r`n
powershell.exe -ExecutionPolicy Bypass -Command `"`$pkgrArgs = '%*'.Split(' '); `$scriptName = '%0'; (Get-Content('%0') | Select -Skip {0}) -Join [Environment]::NewLine | Invoke-Expression`"`r`n
exit`r`n
"@

$exitScript = @"
exit
"@

<#
.SYNOPSIS

Builds a self extracting batch file scripted with Powershell.

.DESCRIPTION

Builds a batch file that bypasses the Windows Powershell execution policy
and launches the internal Powershell script.

.PARAMETER outFile

The file name of the output batch script.

.PARAMETER embeddedFiles

An array of file names of files to package within the script.
#>
function Write-ClownCar
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1)][string]$outFile,
        [Parameter(Mandatory=$true, Position=2)][string]$entryScript,
        [Parameter(Mandatory=$false, Position=3)][string[]]$embeddedFiles)

    [Text.StringBuilder]$buffer = New-Object -TypeName Text.StringBuilder

    <#
    .SYNOPSIS

    Gets the number of lines in a string.

    .PARAMETER string

    The string to count the lines of.
    #>
    function Get-LineCount
    {
        [CmdletBinding()]
        param([Parameter(Mandatory=$true, Position=1)][string]$string)

        $count = 0
        $Local:index = 0

        while ($index -ne -1)
        {
            $index = $string.IndexOf([string]"`r`n", $Local:index + 1)

            if ($Local:index -ne -1)
            {
                $count++
            }
        }

        return $count
    }

    <#
    .SYNOPSIS

    Writes the Clown Car Batch script header to the file.
    #>
    function Write-Header 
    {
        [void]$buffer.Append([string]::Format([string]$BatchTemplateFormat, (Get-LineCount($batchTemplateFormat))))
    }

    <#
    .SYNOPSIS

    Writes the table of files embedded into the script as a hashtable.
    #>
    function Write-FileTable
    {
        [void]$buffer.Append("`$files = @{")
    
        # Embedded files is optional.
        if ($embeddedFiles -eq $null) 
        {
            $offset = 0
            foreach ($file in $embeddedFiles)
            {
                if (-not $file.PSIsContainer)
                {

                    if ($file -ne $embeddedFiles[0])
                    {
                        [void]$buffer.Append(';')
                    }

                    [void]$buffer.Append('"')
                    [void]$buffer.Append(($file | Resolve-Path -Relative))
                    [void]$buffer.Append('"')
                    [void]$buffer.Append('=')
                    [void]$buffer.Append($offset)
                    [void]$buffer.Append(",")
                    [void]$buffer.Append($file.Length)

                    $offset += $file.Length

                }
            }
        }
        [void]$buffer.Append("}`r`n")
    }

    <#
    .SYNOPSIS

    Writes the file size field to the script.
    #>
    function Write-FileSizeField
    {
        $maxFileHeaderSizeLength = 20

        [void]$buffer.Append("`$fileHeaderSize = ")

        $finalFileSize = ($buffer.Length + 
            [System.IO.FileInfo]::new("resources\clown-car-api.psm1").Length + 
            ([System.IO.FileInfo]::new($entryScript).Length + $maxFileHeaderSizeLength) +
            $exitScript.Length)

        for ($i = $finalFileSize.ToString().Length; $i -lt $maxFileHeaderSizeLength; $i++)
        {
            [void]$buffer.Append('0')
        }

        [void]$buffer.Append($finalFileSize)
    }

    <#
    .SYNOPSIS

    Writes the specified files to the script.
    #>
    function Write-FileArchive
    {
        foreach ($embeddedFile in $embeddedFiles)
        {
            try
            {
                Write-Output "Adding $embeddedFile to $outFile"

                $bytes = [System.IO.File]::ReadAllBytes(($embeddedFile | Resolve-Path -Relative))

                [System.IO.FileStream]$fileStream = [System.IO.File]::Open($outFile, [System.IO.FileMode]::Append)

                foreach ($byte in $bytes)
                {
                    $fileStream.WriteByte($byte)
                }

                $fileStream.Close()
            }
            catch [UnauthorizedAccessException], [System.IO.IOException]
            {
                Write-Output "Unable to import $file."
            }
        }
    }

    # Request FileInfo.
    if ($embeddedFiles.Count -gt 0)
    {
        $embeddedFiles = $embeddedFiles | Get-Item
    }

    # Write script headers and variables.
    Write-Header
    Write-FileTable
    Write-FileSizeField
    $buffer.ToString() | Out-File $outFile -Encoding oem
    
    # Write the script API.
    Get-Content "resources\clown-car-api.psm1" | Out-File $outFile -Encoding oem -Append

    # Write the default entry point script.
    Get-Content $entryScript | Out-File $outFile -Encoding oem -Append

    # Write a trailing exit in case user forgets to terminate their script.
    Write-Output $exitScript | Out-File $outFile -Encoding oem -Append

    # Write all of the embedded files to the script.
    Write-FileArchive
}