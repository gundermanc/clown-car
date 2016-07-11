# ClownCar Packaging System
(C) 2016 Christian Gunderman
Contact Email: gundermanc@gmail.com

## Introduction:
ClownCar is a series of Powershell and Batch scripts that work together
to let you package your Powershell projects into a single self-extracting
Windows Batch file containing all files needed by the script.

## How does it work?
ClownCar packs all of your scripts and assets into a batch script that goes
through a bootstrapping process
that launches Powershell via the command line, instructing it to read the
batch file as input, skipping the first few lines, which are batch
instructions. By about line 3, the script has transitioned to a Powershell
script and the CMD interpreter is no longer doing the heavy lifting. Upon
starting, Powershell opens the batch file again, skipping over the batch
file and Powershell sections, and on to the data section, which contains
a ZIP archive, stored in base64 format. This archive is then extracted to
a temporary folder and ClownCar runs the Main() method in the main.psm1
file in the archive. Within the Main file, the developer has four or five
ClownCar functions for interacting with the package loader.

## Value Prospects
  - Bypass the obnoxius security settings for Powershell that require
    code signing. CC does this by embedding your script(s) into a batch
    file which is unrestricted and can bypass the scripting security
    requirements. Now you can run Powershell scripts on any machine!
  - Obfuscates your scripts by embedding them, base64 encoded, within
    a ZIP in the batch file.
  - Allows you to package your script's assets into a single
    self-extracting script containing a ZIP archive with anything you
    want!
  - Provides a nice and easy to use temporary directory for your script
    to play in that is automagically deleted when you return from your
    main function. No need to worry about cleanup, it is taken care of.
  - Assets are extracted to a full-path-known location so users who cd
    to another directory will not break your scripts.
  - Powershell is a very powerful tool! Since it integrates with .NET,
    you have full access to WPF and WinForms and can conceivably build
    a rich client or server application with UI and advanced features.
    Although this is not an ideal scenario, it does have the benefit
    of making it really easy to spin off a small tool or application
    without installing the Microsoft SDKs. Since Powershell is present
    on every computer, this is a HUGE win. ClownCar provides the
    means to package your app into one file.

## Command Line Packager
The command line packager, clown-car.bat, is the tool that produces
self-extractors. It accepts an output name and a directory to ZIP.
To try it out, run it with no arguments for a description of the command
line arguments that it accepts.

```
clown-car [out_batch_file] [assets_dir]
```

### Packager API
To use the packager in your own scripts do the following:
```powershell

Import-Module "resources\clown-car-packager-api.psm1"
Write-ClownCar "outfile.bat" "package_srcs_dir"

```

### ClownCar loader functions
- Get-ClownCarDirectory: Gets the extracted ZIP directory.
- Get-ClownCarScriptName: Gets the self-extractor script file name.
- Get-ClownCarArguments: Gets the arguments the self-extractor recvd.
- Get-ClownCarZipPath: Gets the path to the temporary ZIP file.
- Get-ClownCarMainPath: Gets the path to the main.psm1 file.
- ClownCarCleanupAndExit: Cleans up the ClownCar directory and exits.
- ClownCarExitWithoutCleanup: Exits without cleaning up the directory.

## Why make something so seemingly pointless?
ClownCar was created for the convenience of the network admin or busy dev
who needs to be able to build portable, easily modified tools for use across
many machines. It has several marked advantages over tools made with programming
languages. For one, Powershell is portable to all Windows workstations and
servers and is rather lightweight. Furthermore, the Powershell ISE (the IDE for
Powershell) comes preinstalled on all Windows machines. This means that tweaking
your scripts when working on VMs and on customer machines, which may not have
dev tools installed, is as simple as booting up Powershell.

Secondly, Powershell scripts are small, yet very powerful. You have the entire
Microsoft .NET framework at your disposal, and so, it is very easy to accomplish
a lot with little code. Unfortunately, Powershell is a plain text format, meaning
that any required resources, such as images, LICENSE files, READMEs, HTML, and
REGISTRY dumps have to be transported in the folder with the script. If the user
simply copies the script and forgets to copy the resources directories, the script
will fail in a less than helpful way (lots of red text). ClownCar scripts, however,
are a single self extracting executable script and have a known path that all
resources are extracted to. Because of this, changing the current directory never
causes problems because the script always knows where to find its assets.