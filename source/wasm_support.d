module wasm_support;

import core.stdc.stdlib : abort;

// LDC's BetterC assertion/bounds-failure hook for the Emscripten target.
// Define this once in the final program and retain bounds checking.
extern(C) void __assert(const(char)* message, const(char)* file, uint line) {
    abort();
}
