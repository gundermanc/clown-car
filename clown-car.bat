@echo off

:: Clown Car Powershell + Files -> Batch Script Self Extractor
:: Command line interface
:: By: Christian Gunderman

:: This file exists to bypass Powershell Execution Policy.
powershell.exe -ExecutionPolicy Bypass -Command ".\resources\clown-car-cli" %*
