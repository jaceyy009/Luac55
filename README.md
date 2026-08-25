# Lua 5.5 → Luac WebAssembly

This is a browser-based Lua compiler frontend using the **official Lua 5.5.1 `luac` compiler** compiled to WebAssembly with Emscripten.

## Build

Install/activate Emscripten first:

```bash
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
```

Then from this project:

```bash
./build.sh
```

On Windows PowerShell, after activating Emscripten:

```powershell
.\build.ps1
```

The script downloads Lua 5.5.1 directly from Lua.org, compiles `luac.c` and the required Lua source files, and produces:

```text
web/
  index.html
  luac.js
  luac.wasm
```

## Run

Browsers generally will not load the external `.wasm` module correctly from `file://`. Serve the `web` directory:

```bash
cd web
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080/
```

Emscripten's documentation recommends serving pages containing external WASM instead of relying on `file://`. 

## What the browser does

1. `index.html` loads `luac.js`.
2. Emscripten loads `luac.wasm`.
3. JavaScript writes the Lua source into the compiler's virtual filesystem as `/input.lua`.
4. JavaScript calls the real Lua `luac` entry point with arguments equivalent to:

```text
luac -o /output.luac /input.lua
```

or, when stripping is enabled:

```text
luac -s -o /output.luac /input.lua
```

5. JavaScript reads `/output.luac` from Emscripten's virtual filesystem.
6. The browser creates a Blob and downloads the resulting `.luac`.

No Lua source needs to be sent to a server.

## Important

This produces **Lua 5.5.1 bytecode**, not Lua 5.4 or a custom JavaScript bytecode format. The compiler is built from the official Lua 5.5.1 source.

Lua 5.5.1 is the current Lua 5.5 release at the time this project was created.

## License

Lua is distributed under the Lua license. Keep the official Lua copyright/license information with redistributed Lua source and builds.

Project source:
https://www.lua.org/ftp/lua-5.5.1.tar.gz

Lua source browser:
https://www.lua.org/source/5.5/

Emscripten:
https://emscripten.org/
