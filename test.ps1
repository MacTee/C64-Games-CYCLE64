param([string]$C64Ctl='D:\Projects\Emulator.C64\_builds\c64ctl\c64ctl.exe')
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
    if (!(Test-Path -LiteralPath $C64Ctl)) { throw "c64ctl not found: $C64Ctl" }
    & "$PSScriptRoot\build.ps1" -EngineTests
    $testFile=($PSScriptRoot+'\build\cycle64-tests.prg').Replace('\','/')
    $script=Join-Path $PSScriptRoot 'build\engine-checks.c64s'
    @"
boot pal
inject "$testFile" jump `$4000
until mem:`$cf00=`$a5 max:10s
peek `$cf00:4
expect mem:`$cf01=0

"@ | Out-File -LiteralPath $script -Encoding utf8
    $session='cycle64-tests-'+[Guid]::NewGuid().ToString('N').Substring(0,8)
    & $C64Ctl --s $session play $script --report "$PSScriptRoot\build\engine-report" 2>&1 | Tee-Object -FilePath build/test-result.txt
    if ($LASTEXITCODE -ne 0) { throw 'Engine regression failed; see build/engine-report/report.md' }
    $report=Get-Content "$PSScriptRoot\build\engine-report\report.md" -Raw
    if ($report -notmatch '\$CF00: a5 00 ([0-9a-f]{2}) ([0-9a-f]{2})') { throw 'Missing engine assertion count' }
    $count=[Convert]::ToInt32($Matches[1],16)+256*[Convert]::ToInt32($Matches[2],16)
    ("PASS: $count assertions executed by the emulated PAL C64 CPU in an isolated one-shot session.") | Tee-Object -FilePath build/test-summary.txt
    & "$PSScriptRoot\build.ps1"
} finally { Pop-Location }