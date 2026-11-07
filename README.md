# Extending D betterC Support for WebAssembly

A senior thesis project exploring how D programs compiled in betterC mode can
run as WebAssembly. The repository progresses from standalone Wasm functions to
manually managed dynamic arrays, Emscripten integration, and browser graphics
with SDL3.

## Research Overview

The project investigates how useful D abstractions and browser applications can
be supported without depending on the D runtime. The current implementation
focuses on an explicitly managed array container and the compilation and linking
steps needed to connect D code to JavaScript and SDL3.

The experiments demonstrate two build paths:

- **Standalone WebAssembly:** LDC produces a Wasm module that JavaScript loads
  directly with `WebAssembly.instantiate`.
- **Emscripten:** LDC produces Wasm object files, then `emcc` links them with C
  library support, JavaScript glue, and optionally the SDL3 port.

This repository contains exploratory examples and functional checks. It does not
currently include a performance benchmark suite or measured thesis results.

## Library Components

| File | Purpose |
| --- | --- |
| [source/betterc_array.d](source/betterc_array.d) | `BetterCArray(T)`, a generic growable array backed by `realloc` and `free`, with append, borrowed slices, and explicit cleanup. |
| [source/wasm_support.d](source/wasm_support.d) | Defines LDC's `__assert` hook for the Emscripten target, aborting on assertion or bounds failure. |

See the [array API and ownership guide](docs/betterc-array.md) for usage details.

## Prerequisites

Install the tools required by the experiment you want to run and make them
available on `PATH`:

| Tool | Used by |
| --- | --- |
| LDC (`ldc2`) with WebAssembly target support and a compatible Wasm linker | All experiments |
| Node.js (`node`) | JavaScript checks in experiments 01–04 |
| Emscripten (`emcc`), with its SDK environment activated | Experiments 03–06 |
| DUB (`dub`) | BindBC dependency resolution in experiment 06 |
| Python 3 and a browser with WebAssembly support | Serving browser examples locally |
| Bash | Build and cleanup scripts |

The build scripts use Bash and Unix-style paths. No validated compiler or SDK
version matrix is recorded in this repository. Experiment 06 pins BindBC SDL to
2.4.4 and BindBC Common to 1.0.5 in its dependency selections.

## Quick Start

Run commands from the repository root unless otherwise indicated. The reusable
array example builds and runs its Node.js checks with:

```bash
bash tests/04-emscripten-dynamic-array/build.sh
```

A successful run ends with:

```text
PASS: dynamic array round 1
PASS: dynamic array round 2
PASS: all dynamic array tests
```

To run the same checks in a browser:

```bash
bash tests/04-emscripten-dynamic-array/build-html.sh
python3 -m http.server 8000 -d tests/04-emscripten-dynamic-array/build/web
```

Open <http://localhost:8000> and inspect the browser console for the test output.
Use HTTP serving so the generated JavaScript can load the Wasm file.

## Experiments

### 01 — Basic WebAssembly

Exports an `add` function from D and calls it from Node.js. This example uses the
`wasm32-unknown-unknown-wasm` target and disables bounds checking.

```bash
cd tests/01-basic-wasm
bash build.sh
```

Expected output: `10 + 20 = 30`. Run this script from its own directory because
its source and JavaScript paths are relative to the working directory.

### 02 — Integer Array Without Emscripten

Implements an experimental array using a fixed 65,536-byte memory pool. Growth
allocates a new region and copies elements; the pool does not reclaim old regions.
This is separate from the reusable container in `source/`.

```bash
cd tests/02-int-array
bash build.sh
```

Expected output includes `Test success: true`, length `3`, and elements `10`,
`20`, and `30`. This script also requires its own directory as the working
directory and disables bounds checking.

### 03 — Emscripten Allocation

Compiles D for `wasm32-unknown-emscripten`, then uses `emcc` to supply allocation
support and a modular JavaScript wrapper. The exported function allocates three
integers with `malloc`, sums them, and frees the buffer.

```bash
bash tests/03-emscripten-test/build.sh
```

Expected output: `Result: 60`. Generated files are placed in `build/node/` inside
the experiment directory.

### 04 — Reusable Dynamic Array

Exercises `BetterCArray!int` and `BetterCArray!string` through JavaScript. The D
checks cover capacity growth, retained values, slices, shared views, repeated
cleanup, and reuse. JavaScript checks exported values, lengths, invalid-index
fallbacks, and two rounds of allocation and cleanup on the same module.

Use the commands in [Quick Start](#quick-start). The Node and browser builds are
kept in separate `build/node/` and `build/web/` directories. Both compile
`wasm_support.d` and retain bounds checking.

### 05 — SDL3 Through Direct C Declarations

Declares the required SDL3 functions directly in D, creates a 640 × 480 window,
and clears the renderer to blue. This is a single-render graphics experiment.

```bash
bash tests/05-emscripten-sdl3/build.sh
python3 -m http.server 8000 -d tests/05-emscripten-sdl3/build
```

Open <http://localhost:8000>. Emscripten links SDL3 through `--use-port=sdl3`.

### 06 — SDL3 With BindBC

Uses BindBC's static SDL bindings and splits the application across three files:

- `main.d` initializes SDL and starts the application.
- `sdl_abstraction.d` wraps SDL initialization and shutdown.
- `application.d` owns the window and renderer and registers an Emscripten frame
  callback. Input and update methods are currently placeholders; rendering displays
  the Gravity Jump start screen copied from the game project's assets. This is a
  static image demonstration; its menu text is not interactive.

The BMP is stored in `tests/06-emscripten-bindbc/assets/`. The build uses
`--preload-file assets@/assets` to bundle it into Emscripten's virtual filesystem.
Keep the generated `.data` file beside the HTML, JavaScript, and Wasm files when
serving or sharing the demo. Texture loading happens once during initialization,
and `shutdown()` releases the texture before the renderer and window.

Build from the experiment directory:

```bash
cd tests/06-emscripten-bindbc
bash scripts/build.sh
```

DUB resolves dependency paths and compiles the application and BindBC sources
for WebAssembly in BetterC mode. The build script then runs `scripts/link.sh` to
link the generated archive with Emscripten's SDL3 port and preload the assets.
See the [experiment guide](tests/06-emscripten-bindbc/README.md) for details.

If linking succeeds, serve the generated page:

```bash
python3 -m http.server 8000 -d build/web
```

## Project Structure

```text
source/
├── betterc_array.d                # Reusable betterC array
└── wasm_support.d                 # Emscripten assertion hook
docs/
└── betterc-array.md               # API, ownership, and interoperability
tests/
├── 01-basic-wasm/                 # Standalone exported addition function
├── 02-int-array/                  # Fixed-pool array prototype
├── 03-emscripten-test/            # C allocation through Emscripten
├── 04-emscripten-dynamic-array/   # Reusable array checks in Node/browser
├── 05-emscripten-sdl3/            # SDL3 with direct C declarations
└── 06-emscripten-bindbc/          # BindBC SDL application prototype
```

## Validation and Cleanup

Build scripts 01–04 run their JavaScript checks automatically. Examples 01–03
primarily print results for inspection; example 04 asserts expected values and
sets a failing Node.js exit status on an error. Examples 05–06 require browser
inspection and do not provide automated graphics assertions.

Experiments 03–05 provide `clean.sh` scripts that remove their generated `build/`
directories. Experiments 01–02 provide cleanup scripts for local `.o` and `.wasm`
files; run those from their respective directories. Their cleanup commands can
report an error when matching artifacts do not exist. Experiment 06 provides
`scripts/clean.sh` to remove its `build/` and local `.dub/` directories. Generated `.o`, `.wasm`, and per-experiment `build/` directories
are ignored by Git.

## Troubleshooting

- **`ldc2`, `emcc`, or `dub` not found:** install the required tool and activate
  its environment in the shell running the script.
- **Unsupported target or incompatible objects:** confirm that LDC supports the
  script's Wasm target and that its output is compatible with your Emscripten
  toolchain. Keep native and Wasm objects separate.
- **Browser cannot load Wasm:** serve the complete generated output directory
  over HTTP and check the browser console for the failing request.
- **Undefined `__assert` in an Emscripten array build:** include
  `source/wasm_support.d` once in the final program, as experiment 04 does.
- **Missing BindBC sources or symbols:** check the cache paths and the additional
  module compilation limitation described in experiment 06.

## License

MIT License. You are free to use any of this code without explicit permission from the author, but with citation.

## Author

David Rodriguez
