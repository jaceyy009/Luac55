#!/usr/bin/env bash
set -euo pipefail

# Build the official Lua 5.5.1 luac compiler for the browser.
# Requirements:
#   - Emscripten SDK (emsdk) installed and activated
#   - curl, tar
#
# Example:
#   source /path/to/emsdk/emsdk_env.sh
#   ./build.sh

LUA_VERSION="5.5.1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if ! command -v emcc >/dev/null 2>&1; then
  echo "emcc was not found. Activate Emscripten first:"
  echo "  source /path/to/emsdk/emsdk_env.sh"
  exit 1
fi

if [ ! -d "lua-${LUA_VERSION}" ]; then
  curl -L -o "lua-${LUA_VERSION}.tar.gz" \
    "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz"
  tar -xzf "lua-${LUA_VERSION}.tar.gz"
fi

mkdir -p web

# Lua's luac consists of luac.c plus the compiler/runtime core.
# We deliberately use the official Lua 5.5.1 source rather than a
# JavaScript reimplementation so the generated chunks are genuine Lua 5.5.1.
SRC="lua-${LUA_VERSION}/src"

emcc \
  "$SRC/luac.c" \
  "$SRC/lapi.c" \
  "$SRC/lcode.c" \
  "$SRC/lctype.c" \
  "$SRC/ldebug.c" \
  "$SRC/ldo.c" \
  "$SRC/ldump.c" \
  "$SRC/lfunc.c" \
  "$SRC/lgc.c" \
  "$SRC/llex.c" \
  "$SRC/lmem.c" \
  "$SRC/lobject.c" \
  "$SRC/lopcodes.c" \
  "$SRC/lparser.c" \
  "$SRC/lstate.c" \
  "$SRC/lstring.c" \
  "$SRC/ltable.c" \
  "$SRC/ltm.c" \
  "$SRC/lundump.c" \
  "$SRC/lvm.c" \
  "$SRC/lzio.c" \
  "$SRC/lcorolib.c" \
  "$SRC/lmathlib.c" \
  "$SRC/lstrlib.c" \
  "$SRC/ltablib.c" \
  "$SRC/lutf8lib.c" \
  "$SRC/linit.c" \
  -I"$SRC" \
  -O3 \
  -sMODULARIZE=1 \
  -sEXPORT_ES6=1 \
  -sFORCE_FILESYSTEM=1 \
  -sEXPORTED_RUNTIME_METHODS='["FS","callMain"]' \
  -sEXIT_RUNTIME=0 \
  -sALLOW_MEMORY_GROWTH=1 \
  -o web/luac.js

cp "$(dirname "$0")/web/index.html" web/index.html

echo
echo "Built:"
echo "  web/index.html"
echo "  web/luac.js"
echo "  web/luac.wasm"
echo
echo "Serve the web/ directory with a local HTTP server."
echo "Do not use file:// because browsers normally block local WASM/module loading."
