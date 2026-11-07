# Emscripten with BindBC-SDL

With LDC, DUB, and the activated Emscripten SDK on PATH, run:

```bash
bash scripts/build.sh
```

The script first runs this DUB command from this directory (this command alone
only produces the archive):

```bash
dub build --compiler=ldc2 --arch=wasm32-unknown-emscripten --combined
```

`dub.json` selects the D source files, BetterC mode, static BindBC bindings,
SDL 3.4.2 declarations, and the Emscripten target. DUB supplies dependency import
paths. `--combined` includes dependency sources in the same compilation so they
receive the same target and version flags. The output is a WebAssembly static
archive at `build/web/libapplication.a`.

After DUB succeeds, `scripts/build.sh` always runs `scripts/link.sh`, which links that archive with Emscripten's
SDL3 port and preloads `assets/`. The BindBC version identifier selects D
declarations; the installed Emscripten SDL3 port determines the SDL implementation.

Serve the output with:

```bash
python3 -m http.server 8000 -d build/web
```

Open http://localhost:8000. Keep the generated HTML, JavaScript, Wasm, and data
files together. To force D compilation again, run `bash scripts/build.sh --force`.

Remove generated build output and the local DUB cache with:

```bash
bash scripts/clean.sh
```

The scripts work from any working directory. Shared dependency caches are retained.
