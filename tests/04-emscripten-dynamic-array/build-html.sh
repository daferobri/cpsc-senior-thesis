#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p build/web

ldc2 \
    -mtriple=wasm32-unknown-emscripten \
    -betterC \
    -c \
    -of=build/web/main.o \
    main.d

emcc build/web/main.o \
    -o build/web/main.js \
    -sMODULARIZE=1 \
    -sEXPORT_NAME=createModule \
    -sENVIRONMENT=web \
    -sALLOW_MEMORY_GROWTH=1 \
    -sEXPORTED_FUNCTIONS='["_testNumArray","_getNum","_getNumLength","_testNumFreeMemory","_testStringArray","_getString","_getStringLength","_testStringFreeMemory"]' \
    -sEXPORTED_RUNTIME_METHODS='["ccall"]' \
    --no-entry

cp index.html test.js build/web/

echo "Browser build complete."
echo "Run: python3 -m http.server 8000 -d build/web"