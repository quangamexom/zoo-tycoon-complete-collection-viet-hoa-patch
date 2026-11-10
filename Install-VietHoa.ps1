param(
    [Parameter(Mandatory = $true)][string]$GameDir,
    [string]$XdeltaPath = ''
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $GameDir).Path
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'patch_manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $XdeltaPath) { $XdeltaPath = Join-Path $PSScriptRoot 'third_party/xdelta3.exe' }
$xdelta = (Get-Command $XdeltaPath -ErrorAction Stop).Source

function Hash([string]$path) {
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($path)
    try { [BitConverter]::ToString($algorithm.ComputeHash($stream)).Replace('-', '').ToLowerInvariant() }
    finally { $stream.Dispose(); $algorithm.Dispose() }
}
function Require-Hash([string]$path, [string]$expected) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Thiếu file: $path" }
    if ((Hash $path) -ne $expected.ToLowerInvariant()) { throw "Sai phiên bản hoặc file đã bị sửa: $path" }
}

if (Get-Process -Name zoo -ErrorAction SilentlyContinue) { throw 'Hãy thoát game trước khi cài patch.' }
Require-Hash (Join-Path $root 'zoo.exe') $manifest.game_exe_sha256
Require-Hash (Join-Path $root 'ijl15.dll') $manifest.prior_ijl15_sha256
foreach ($needed in @('ijl15_org.dll', 'ztpatch.ini', 'zoo.ini')) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $needed) -PathType Leaf)) {
        throw "Bản game này thiếu $needed. Bản vá chỉ dành cho bản Complete Collection tương thích."
    }
}
foreach ($item in $manifest.patches) {
    Require-Hash (Join-Path $root $item.path) $item.base_sha256
    Require-Hash (Join-Path $PSScriptRoot ('deltas/' + $item.path + '.xdelta')) $item.delta_sha256
}
Require-Hash (Join-Path $PSScriptRoot 'payload/ijl15.dll') $manifest.proxy_ijl15_sha256
Require-Hash (Join-Path $PSScriptRoot 'payload/Zoo Tycoon Viet Hoa.cmd') $manifest.launcher_sha256

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $root ('BACKUP_BEFORE_VIET_HOA_' + $stamp)
if (Test-Path -LiteralPath $backup) { throw "Thư mục sao lưu đã tồn tại: $backup" }
$stage = Join-Path $backup '_staged'
New-Item -ItemType Directory -Path $stage -Force | Out-Null

# Prepare and verify every replacement before touching a game file.
foreach ($item in $manifest.patches) {
    $source = Join-Path $root $item.path
    $delta = Join-Path $PSScriptRoot ('deltas/' + $item.path + '.xdelta')
    $output = Join-Path $stage $item.path
    New-Item -ItemType Directory -Path (Split-Path $output -Parent) -Force | Out-Null
    & $xdelta -d -f -s $source $delta $output
    if ($LASTEXITCODE -ne 0) { throw "Không giải mã được patch: $($item.path)" }
    Require-Hash $output $item.target_sha256
}
$ini = Join-Path $root 'zoo.ini'
$iniText = [System.IO.File]::ReadAllText($ini, [Text.Encoding]::GetEncoding(1252))
foreach ($setting in @('fullscreen', 'screenwidth', 'screenheight')) {
    $pattern = '(?im)^(' + $setting + '[ \t]*=[ \t]*)[^\r\n]*'
    if ([regex]::Matches($iniText, $pattern).Count -ne 1) { throw "Thiếu hoặc trùng cài đặt $setting trong zoo.ini" }
    $value = [string]$manifest.window.$setting
    $iniText = [regex]::Replace($iniText, $pattern, '${1}' + $value)
}
$stagedIni = Join-Path $stage 'zoo.ini'
[System.IO.File]::WriteAllText($stagedIni, $iniText, [Text.Encoding]::GetEncoding(1252))

$replace = @($manifest.patches | ForEach-Object { [string]$_.path }) + @('ijl15.dll', 'zoo.ini')
$launcher = 'Zoo Tycoon Viet Hoa.cmd'
$hadLauncher = Test-Path -LiteralPath (Join-Path $root $launcher) -PathType Leaf
$hadPatchDll = Test-Path -LiteralPath (Join-Path $root 'ijl15_patch.dll') -PathType Leaf
if ($hadPatchDll) { Require-Hash (Join-Path $root 'ijl15_patch.dll') $manifest.prior_ijl15_sha256 }
if ($hadLauncher) { $replace += $launcher }
if ($hadPatchDll) { $replace += 'ijl15_patch.dll' }
foreach ($name in $replace) {
    $dest = Join-Path $backup $name
    New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $root $name) -Destination $dest
}

try {
    foreach ($item in $manifest.patches) {
        Copy-Item -LiteralPath (Join-Path $stage $item.path) -Destination (Join-Path $root $item.path) -Force
    }
    if (-not $hadPatchDll) {
        Copy-Item -LiteralPath (Join-Path $backup 'ijl15.dll') -Destination (Join-Path $root 'ijl15_patch.dll')
    }
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'payload/ijl15.dll') -Destination (Join-Path $root 'ijl15.dll') -Force
    Copy-Item -LiteralPath $stagedIni -Destination $ini -Force
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot ('payload/' + $launcher)) -Destination (Join-Path $root $launcher) -Force
    foreach ($item in $manifest.patches) { Require-Hash (Join-Path $root $item.path) $item.target_sha256 }
    Require-Hash (Join-Path $root 'ijl15.dll') $manifest.proxy_ijl15_sha256
    Require-Hash (Join-Path $root 'ijl15_patch.dll') $manifest.prior_ijl15_sha256
    Require-Hash (Join-Path $root $launcher) $manifest.launcher_sha256
} catch {
    foreach ($name in $replace) {
        Copy-Item -LiteralPath (Join-Path $backup $name) -Destination (Join-Path $root $name) -Force
    }
    if (-not $hadLauncher -and (Test-Path -LiteralPath (Join-Path $root $launcher))) {
        Remove-Item -LiteralPath (Join-Path $root $launcher) -Force
    }
    if (-not $hadPatchDll -and (Test-Path -LiteralPath (Join-Path $root 'ijl15_patch.dll'))) {
        Remove-Item -LiteralPath (Join-Path $root 'ijl15_patch.dll') -Force
    }
    throw
}
Write-Host "Đã cài patch. Bản sao lưu: $backup"
Write-Host "Mở game: $(Join-Path $root $launcher)"
