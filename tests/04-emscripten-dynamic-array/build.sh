#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p build/node

ldc2 \
    -mtriple=wasm32-unknown-emscripten \
    -betterC \
    -c \
    -of=build/node/main.o \
    main.d

emcc build/node/main.o \
    -o build/node/main.js \
    -sMODULARIZE=1 \
    -sENVIRONMENT=node \
    -sALLOW_MEMORY_GROWTH=1 \
    -sEXPORTED_FUNCTIONS='["_testNumArray","_getNum","_getNumLength","_testNumFreeMemory","_testStringArray","_getString","_getStringLength","_testStringFreeMemory"]' \
    -sEXPORTED_RUNTIME_METHODS='["ccall"]' \
    --no-entry

cp test.js build/node/

node build/node/test.js