@echo off
color 0A
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass ^
-Command "Start-Process '%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0orig\tools.ps1\"' -Verb RunAs"
