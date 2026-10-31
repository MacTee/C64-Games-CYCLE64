param(
    [string]$Vice = 'D:\Projects\Emulator.C64\_programs\_GTK3VICE-3.8-win64\bin\x64sc.exe',
    [switch]$Monitor,
    [int]$Port=6510
)
$ErrorActionPreference='Stop'
if (!(Test-Path -LiteralPath $Vice)) { throw "VICE not found: $Vice" }
$prg=Join-Path $PSScriptRoot 'build\cycle64.prg'
if (!(Test-Path -LiteralPath $prg)) { throw 'Build first: .\build.ps1' }
$viceArgs=@('-default','-pal','-autostart-handle-tde','-autostartprgmode','0')
if ($Monitor) { $viceArgs+=@('-remotemonitor','-remotemonitoraddress',"127.0.0.1:$Port") }
$viceArgs+=@('-autostart',('"'+$prg+'"'),'-logfile',('"'+(Join-Path $PSScriptRoot 'build\vice.log')+'"'))
# VICE is the interactive game window requested by the user.
Start-Process -FilePath $Vice -ArgumentList $viceArgs -WorkingDirectory $PSScriptRoot
