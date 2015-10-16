# BEGIN 

<#
.SYNOPSIS

Gets the name of the currently executing script file.

.DESCRIPTION

This function replaces the default Powershell $MyInvocation.ScriptName value.
Since your script is embedded inside of a batch file and piped in line by line,
the conventional method does not work.

#>
function Get-ScriptName
{
    [CmdletBinding()]Param()

    process 
    {
        return $scriptName
    }
}

<#
.SYNOPSIS

Checks the self extracting batch file for the specified file.

.DESCRIPTION

Checks to see if the specified path is the name of a file within the script.
File names are relative paths per the way the script was created in the first
place.

.PARAMETER extractFileName

The relative path of the file to extract from the table.
#>
function Test-EmbeddedFileExists
{
    [CmdletBinding()]
    Param([Parameter(Mandatory=$true, Position=1)]$embeddedFileName)

    return $files.ContainsKey($embeddedFileName)
}

<#
.SYNOPSIS

Extracts a file embedded in the self extracting batch script.

.DESCRIPTION

Checks if a file with the specified relative path exists within the
script package. If so, file is extracted. Returns true on success.

.PARAMETER embeddedFileName

The relative path of the file stored within this script.

.PARAMETER destinationFileName

The path to the file where the embedded file will be extracted.
#>
function Extract-EmbeddedFile
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, Position=1)][string]$embeddedFileName,
        [Parameter(Mandatory=$true, Position=2)][string]$destinationFileName)
        
    if (-not (Test-EmbeddedFileExists $embeddedFileName))
    {
        return $false
    }

    $tuple = $files[$embeddedFileName]
    $offset = $tuple[0]
    $bytes = $tuple[1]
    
    if (Test-Path $destinationFileName)
    {
        Remove-Item $destinationFileName -ErrorAction Inquire
    }

    [System.IO.FileStream]$inFile = [System.IO.File]::OpenRead((Get-ScriptName))
    [System.IO.FileStream]$outFile = [System.IO.File]::OpenWrite($destinationFileName)

    [void]$inFile.Seek($fileHeaderSize + $offset, [System.IO.SeekOrigin]::Begin);

    [int]$byte = 0
    [long]$bytesWritten = 0

    while ((($byte = $inFile.ReadByte()) -ne (-1)) -and $bytesWritten -lt $bytes)
    {
        $outFile.WriteByte($byte)
        $bytesWritten++
    }

    $inFile.Close()
    $outFile.Close()

    return $true
}

<#
.SYNOPSIS

Gets the arguments passed to the script.

.DESCRIPTION

Because the script is delivered in the form of a self extracting batch file and
the inner scripts are executed by piping in the commands the default $args variable
does not work. This function supercedes that functionality.
#>
function Get-Arguments
{
    [CmdletBinding()]Param()

    return $pkgrArgs
}

<#
.SYNOPSIS

Gets a list of all of the embedded file paths.
#>
function Get-EmbeddedFiles
{
    [CmdLetBinding()]Param()
    return $files.Keys
}

# END POWERSHELL TEMPLATE