#!/usr/bin/env bash
set -euo pipefail

ldc2 \
    -mtriple=wasm32-unknown-unknown-wasm \
    -betterC \
    -boundscheck=off \
    -of=array.wasm \
    main.d \
    -L--no-entry \
    -L--export=testArray \
    -L--export=getLength \
    -L--export=getElement \

node test.js