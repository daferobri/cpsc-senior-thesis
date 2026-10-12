#!/usr/bin/env bash
set -euo pipefail

ldc2 \
    -mtriple=wasm32-unknown-unknown-wasm \
    -betterC \
    -boundscheck=off \
    -of=basic.wasm \
    main.d \
    -L--no-entry \
    -L--export=add \

node test.js