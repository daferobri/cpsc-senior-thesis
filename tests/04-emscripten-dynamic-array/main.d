import betterc_array : BetterCArray;

extern(C):

// Exercise the container directly without adding new JavaScript exports.
// Local arrays own their buffers; do not copy them after allocating.
private bool checkIntEdgeCases() {
    BetterCArray!int array;
    if (!array.isEmpty() || array.length() != 0 ||
        array.getCapacity() != 0) return false;

    array.freeMemory();
    array.freeMemory();

    // Cross 4, 8, 16, ... capacity boundaries and check every retained value.
    foreach (i; 0 .. 257) {
        if (!array.push(i - 128)) {
            array.freeMemory();
            return false;
        }
        size_t expectedCapacity = 4;
        while (expectedCapacity < cast(size_t)(i + 1))
            expectedCapacity *= 2;
        if (array.length() != cast(size_t)(i + 1) ||
            array.getCapacity() != expectedCapacity || array.isEmpty()) {
            array.freeMemory();
            return false;
        }
        foreach (j; 0 .. i + 1) {
            if (array.get(cast(size_t) j) != j - 128) {
                array.freeMemory();
                return false;
            }
        }
    }

    array.freeMemory();
    array.freeMemory();
    if (!array.isEmpty() || array.length() != 0 ||
        array.getCapacity() != 0) return false;

    // Reuse after freeing, including values that can resemble sentinels.
    if (!array.push(int.min) || !array.push(-1) ||
        !array.push(0) || !array.push(int.max)) {
        array.freeMemory();
        return false;
    }
    bool valid = array.length() == 4 && array.getCapacity() == 4
        && array.get(0) == int.min && array.get(1) == -1
        && array.get(2) == 0 && array.get(3) == int.max;
    array.freeMemory();
    return valid;
}

private bool checkStringEdgeCases() {
    BetterCArray!string array;
    // These literals have static lifetime. The container owns the slice
    // buffer, not the character data referenced by each string.
    string[5] samples = ["", "A", "Hello", "two words", "longer string sample"];
    foreach (i; 0 .. 65) {
        if (!array.push(samples[i % samples.length])) {
            array.freeMemory();
            return false;
        }
        foreach (j; 0 .. i + 1) {
            auto actual = array.get(cast(size_t) j);
            auto expected = samples[j % samples.length];
            if (actual.length != expected.length) {
                array.freeMemory();
                return false;
            }
            foreach (k; 0 .. expected.length) {
                if (actual[k] != expected[k]) {
                    array.freeMemory();
                    return false;
                }
            }
        }
    }
    array.freeMemory();
    array.freeMemory();
    if (!array.isEmpty() || array.length() != 0 ||
        array.getCapacity() != 0) return false;
    if (!array.push("A")) return false;
    bool valid = array.length() == 1 && array.getCapacity() == 4
        && array.get(0).length == 1 && array.get(0)[0] == 'A';
    array.freeMemory();
    return valid;
}

__gshared BetterCArray!int numbers;

int testNumArray() {
    if (!checkIntEdgeCases()) return 0;
    foreach (i; 1 .. 100) {
        if (!numbers.push(i)) return 0;
        
    }
    return 1;
}

int getNum(int index) {
    if (index < 0 ||
        cast(size_t) index >= numbers.length())
        return -1;

    return numbers.get(cast(size_t) index);
}

int getNumLength() {
    return cast(int) numbers.length();
}

int testNumFreeMemory() {
    numbers.freeMemory();
    return numbers.length() == 0
        && numbers.isEmpty()
        && numbers.getCapacity() == 0;
}

__gshared BetterCArray!string words;

int testStringArray() {
    if (!checkStringEdgeCases()) return 0;
    foreach (i; 1 .. 100) {
        if (!words.push("Hello")) return 0;
    }
    return 1;
}

const(char)* getString(int index) {
    if (index < 0 ||
        cast(size_t) index >= words.length())
        return "";

    return words.get(cast(size_t) index).ptr;
}

int getStringLength() {
    return cast(int) words.length();
}

int testStringFreeMemory() {
    words.freeMemory();
    return words.length() == 0
        && words.isEmpty()
        && words.getCapacity() == 0;
}