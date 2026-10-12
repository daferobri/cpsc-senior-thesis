#!/usr/bin/env bash
set -euo pipefail

ldc2 \
    -mtriple=wasm32-unknown-emscripten \
    -betterC \
    -c \
    -of=array.o \
    array.d

emcc array.o \
    -o array.js \
    -sMODULARIZE=1 \
    -sENVIRONMENT=node \
    -sALLOW_MEMORY_GROWTH=1 \
    -sEXPORTED_FUNCTIONS='["_testAllocation"]' \
    -sEXPORTED_RUNTIME_METHODS='["ccall"]' \
    --no-entry

node test.js