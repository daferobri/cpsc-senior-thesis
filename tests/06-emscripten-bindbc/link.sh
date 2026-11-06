#!/usr/bin/env bash
emcc build/main.o \
    -o build/index.html \
    --use-port=sdl3 \
    -sALLOW_MEMORY_GROWTH=1 \
    -sASSERTIONS=2 \
    -g
