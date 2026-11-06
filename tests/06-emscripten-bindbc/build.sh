#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build/web

# DUB resolves dependencies; LDC must compile all required modules for Wasm.
# Override these paths if your DUB package cache uses a different layout.
SDL_DIR="${SDL_DIR:-$HOME/.dub/packages/bindbc-sdl/2.4.4/bindbc-sdl/source}"
COMMON_DIR="${COMMON_DIR:-$HOME/.dub/packages/bindbc-common/1.0.5/bindbc-common/source}"
if [[ ! -d "$SDL_DIR" || ! -d "$COMMON_DIR" ]]; then
    echo "BindBC sources not found. Run: dub describe --data=import-paths" >&2
    echo "Set SDL_DIR and COMMON_DIR to the respective source directories." >&2
    exit 1
fi

ldc2 -mtriple=wasm32-unknown-emscripten -betterC \
    -d-version=BindSDL_Static \
    -I"$SDL_DIR" -I"$COMMON_DIR" \
    -c -od=build/web \
    main.d application.d sdl_abstraction.d

# Some BindBC modules may also need to be compiled as Wasm objects.
# Never link the native .dub/cache/*.a archives here.
emcc build/web/*.o -o build/web/index.html \
    --use-port=sdl3 --preload-file assets@/assets \
    -sALLOW_MEMORY_GROWTH=1 -sASSERTIONS=2 -g
