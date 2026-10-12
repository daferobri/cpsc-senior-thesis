#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p build/node

ldc2 \
    -mtriple=wasm32-unknown-emscripten \
    -betterC \
    -c \
    -of=build/node/array.o \
    array.d

emcc build/node/array.o \
    -o build/node/array.js \
    -sMODULARIZE=1 \
    -sENVIRONMENT=node \
    -sALLOW_MEMORY_GROWTH=1 \
    -sEXPORTED_FUNCTIONS='["_testAllocation"]' \
    -sEXPORTED_RUNTIME_METHODS='["ccall"]' \
    --no-entry

cp test.js build/node/

node build/node/test.js