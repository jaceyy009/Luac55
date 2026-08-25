$ErrorActionPreference = "Stop"

$LuaVersion = "5.5.1"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

if (-not (Get-Command emcc -ErrorAction SilentlyContinue)) {
    Write-Error "emcc was not found. Activate your Emscripten environment first."
}

$Archive = "lua-$LuaVersion.tar.gz"
$Dir = "lua-$LuaVersion"

if (-not (Test-Path $Dir)) {
    Invoke-WebRequest "https://www.lua.org/ftp/$Archive" -OutFile $Archive
    tar -xzf $Archive
}

New-Item -ItemType Directory -Force web | Out-Null
$S = "$Dir/src"

$sources = @(
  "luac.c","lapi.c","lcode.c","lctype.c","ldebug.c","ldo.c","ldump.c",
  "lfunc.c","lgc.c","llex.c","lmem.c","lobject.c","lopcodes.c","lparser.c",
  "lstate.c","lstring.c","ltable.c","ltm.c","lundump.c","lvm.c","lzio.c",
  "lcorolib.c","lmathlib.c","lstrlib.c","ltablib.c","lutf8lib.c","linit.c"
) | ForEach-Object { Join-Path $S $_ }

& emcc @sources `
  "-I$S" `
  "-O3" `
  "-sMODULARIZE=1" `
  "-sEXPORT_ES6=1" `
  "-sFORCE_FILESYSTEM=1" `
  '-sEXPORTED_RUNTIME_METHODS=["FS","callMain"]' `
  "-sEXIT_RUNTIME=0" `
  "-sALLOW_MEMORY_GROWTH=1" `
  "-o" "web/luac.js"

Copy-Item "web/index.html" "web/index.html" -Force
Write-Host "Built web/luac.js and web/luac.wasm"
