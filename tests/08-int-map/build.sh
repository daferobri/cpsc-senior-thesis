#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p build/node

ldc2 \
    -mtriple=wasm32-unknown-emscripten \
    -betterC \
    -checkaction=halt \
    -i \
    -c \
    -of=build/node/aa.o \
    test.d

emcc build/node/aa.o \
    -o build/node/aa.js \
    -sMODULARIZE=1 \
    -sENVIRONMENT=node \
    -sALLOW_MEMORY_GROWTH=1 \
    -sEXPORTED_FUNCTIONS='["_testInsertAndFind"]' \
    -sEXPORTED_RUNTIME_METHODS='["ccall"]' \
    --no-entry

cp test.js build/node/

node build/node/test.js