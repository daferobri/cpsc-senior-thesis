
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p build

ldc2 \
    -mtriple=wasm32-unknown-emscripten \
    -betterC \
    -c \
    -of=build/main.o \
    main.d

emcc build/main.o \
    -o build/index.html \
    --use-port=sdl3 \
    -sALLOW_MEMORY_GROWTH=1 \
    -sASSERTIONS=2 \
    -g
