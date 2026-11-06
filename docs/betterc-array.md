# BetterCArray API and Ownership

[`BetterCArray(T)`](../source/betterc_array.d) stores elements in a contiguous
buffer managed with C's `realloc` and `free`. It starts with zero length and
capacity, allocates room for four elements on the first append, and doubles
capacity when full. Growth checks capacity and byte-size overflow before
requesting memory.

## Basic Usage

```d
import betterc_array : BetterCArray;

extern(C) int main() {
    BetterCArray!int numbers;
    if (!numbers.push(10)) return 1;
    if (!(numbers ~= 20)) return 1;

    auto values = numbers[];
    values[0] = 42; // The view shares the array's storage.
    if (numbers.get(0) != 42 || numbers.length() != 2) return 1;

    values = null; // Discard borrowed views before releasing storage.
    numbers.freeMemory();
    return 0;
}
```

Build a native example saved as `example.d` at the repository root with:

```bash
ldc2 -betterC -Isource example.d source/betterc_array.d -of=example
./example
```

For a complete Emscripten build and JavaScript caller, see
[`tests/04-emscripten-dynamic-array`](../tests/04-emscripten-dynamic-array/).
Its scripts compile the array module and assertion hook, then link with `emcc`.

## API

| Operation | Behavior |
| --- | --- |
| `push(element)` | Appends one element; returns `false` if capacity growth overflows or allocation fails. A failed growth preserves the existing buffer and length. |
| `array ~= element` | Calls `push` and returns its Boolean result. Check it when allocation failure matters. |
| `length()` | Returns the number of stored elements. |
| `getCapacity()` | Returns the number of elements that fit before another growth allocation. |
| `get(index)` | Returns an element by value. The caller must ensure `index < length()`; this pointer access has no explicit bounds check. |
| `isEmpty()` | Tests whether the backing pointer is null. For this append/free API, that corresponds to zero length. |
| `array[]` | Returns a mutable borrowed slice of all elements. |
| `array[start .. end]` | Returns a mutable borrowed slice after asserting `start <= end <= length()`. |
| `$` in slicing | Uses `opDollar()` to obtain the current length, as in `array[1 .. $]`. |
| `freeMemory()` | Frees storage and resets pointer, length, and capacity. Repeated calls are supported. |
| Destructor | Calls `freeMemory()` when the owner is destroyed. |

Empty slices return null slices with length zero, including empty subranges of
nonempty arrays. Slice range validation uses assertions, so retain assertion
checks when relying on that validation.

## Ownership and Element Types

Each array owns its buffer. Copy construction is disabled to prevent duplicated
ownership; pass owners by reference when sharing access. Explicitly free
long-lived or `__gshared` arrays when they are no longer needed. A local owner's
destructor provides scope cleanup, including after an explicit `freeMemory()`.

Slices borrow the owner's memory. Mutations through a slice affect the array
and overlapping slices. Discard views before any append that might reallocate,
before `freeMemory()`, and before the owner leaves scope. The implementation
does not track borrowed views or keep their buffers alive.

The container manages raw storage. It does not implement per-element destruction
or relocation hooks, so use element types appropriate for C-style reallocation,
such as integers and borrowed descriptors. It does not synchronize concurrent
access.

For `BetterCArray!string`, each element is a D string slice descriptor. The
container owns the buffer of descriptors; it does not allocate, copy, or free
the character data they reference. The character data must outlive its use in
the array. The checked-in examples use string literals with static lifetime.

## JavaScript Interoperability

Experiment 04 wraps global array instances in `extern(C)` functions and explicitly
exports them during Emscripten linking. JavaScript uses `ccall` to invoke those
functions. The wrappers validate indices: invalid integer reads return `-1`, and
invalid string reads return an empty string. These fallback rules belong to the
example wrappers, not to `BetterCArray.get`.

The example's `getString` returns a character pointer and JavaScript reads it as
a C string. General D strings carry a length and need not be null-terminated;
for arbitrary strings, provide an explicit length or a null-terminated copy
instead of assuming that this literal-based example handles every string.

[`wasm_support.d`](../source/wasm_support.d) supplies the Emscripten assertion
hook used by experiment 04. It aborts rather than reporting assertion text.
Define that hook once in a final program and retain bounds checking, following
the experiment's build scripts.
