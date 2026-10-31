param(
    [string]$Java = 'D:\Projects\Emulator.C64\_programs\Jdk18.0.2\bin\java.exe',
    [string]$KickAss = 'D:\Projects\Emulator.C64\_programs\_kickass\5.25\KickAss.jar',
    [switch]$EngineTests
)
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    if (!(Test-Path -LiteralPath $Java)) { throw "Java not found: $Java" }
    if (!(Test-Path -LiteralPath $KickAss)) { throw "Kick Assembler not found: $KickAss" }
    New-Item -ItemType Directory -Force -Path build | Out-Null
    $options=@()
    $output='build/cycle64.prg'
    if ($EngineTests) { $options=@('-define','ENGINE_TESTS'); $output='build/cycle64-tests.prg' }
    $compilerOutput = & $Java -jar $KickAss src/main.asm -o $output -symbolfile -symbolfiledir "$PSScriptRoot\build" -vicesymbols -showmem @options 2>&1
    $compilerOutput | Tee-Object -FilePath build/assembly.log
    if ($LASTEXITCODE -ne 0 -or ($compilerOutput -match 'FAILED!')) { throw "Assembly failed or a layout assertion failed ($LASTEXITCODE)" }
    Get-FileHash -LiteralPath $output -Algorithm SHA256 | Format-List
} finally { Pop-Location }
