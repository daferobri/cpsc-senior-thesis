#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p build/node

for module in main betterc_array wasm_support; do
    if [[ "$module" == main ]]; then
        source_file=main.d
    else
        source_file="../../source/$module.d"
    fi

    ldc2 \
        -mtriple=wasm32-unknown-emscripten \
        -betterC \
        -I../../source \
        -c \
        -of="build/node/$module.o" \
        "$source_file"
done

emcc build/node/main.o \
    build/node/betterc_array.o \
    build/node/wasm_support.o \
    -o build/node/main.js \
    -sMODULARIZE=1 \
    -sENVIRONMENT=node \
    -sALLOW_MEMORY_GROWTH=1 \
    -sEXPORTED_FUNCTIONS='["_testNumArray","_getNum","_getNumLength","_testNumFreeMemory","_testStringArray","_getString","_getStringLength","_testStringFreeMemory"]' \
    -sEXPORTED_RUNTIME_METHODS='["ccall"]' \
    --no-entry

cp test.js build/node/

node build/node/test.js