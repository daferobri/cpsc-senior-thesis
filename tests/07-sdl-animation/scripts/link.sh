#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Link only the Wasm archive produced by DUB, avoiding stale object files.
emcc build/web/libapplication.a -o build/web/index.html \
    --use-port=sdl3 --preload-file assets@/assets \
    -sALLOW_MEMORY_GROWTH=1 -sASSERTIONS=2 -g
