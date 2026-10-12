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

private bool checkIntSlices() {
    BetterCArray!int array;
    if (array[].length != 0 || array[0 .. 0].length != 0 ||
        array[0 .. $].length != 0) return false;

    foreach (i; 0 .. 9) {
        if (!(array ~= i * 10)) return false;
    }
    auto capacity = array.getCapacity();
    auto all = array[];
    if (all.length != 9) return false;
    foreach (i; 0 .. all.length) {
        if (all[i] != cast(int) i * 10) return false;
    }

    auto middle = array[2 .. 5];
    if (middle.length != 3 || middle[0] != 20 ||
        middle[1] != 30 || middle[2] != 40) return false;
    auto tail = array[7 .. $];
    if (tail.length != 2 || tail[0] != 70 || tail[1] != 80)
        return false;
    if (array[0 .. 0].length != 0 || array[4 .. 4].length != 0 ||
        array[$ .. $].length != 0) return false;

    // Overlapping views share the owner's storage.
    middle[0] = -20;
    if (array.get(2) != -20 || all[2] != -20) return false;
    all[8] = 123;
    if (tail[1] != 123 || array.get(8) != 123) return false;
    if (array.length() != 9 || array.getCapacity() != capacity)
        return false;

    // Never access old views after a possible reallocation.
    all = null;
    middle = null;
    tail = null;
    foreach (i; 9 .. 33) {
        if (!(array ~= i * 10)) return false;
    }
    auto fresh = array[30 .. $];
    if (fresh.length != 3 || fresh[0] != 300 ||
        fresh[1] != 310 || fresh[2] != 320) return false;
    fresh = null;
    array.freeMemory();
    if (array[].length != 0 || array[0 .. $].length != 0)
        return false;
    if (!(array ~= 42)) return false;
    return array[].length == 1 && array[][0] == 42;
}

private bool checkStringSlices() {
    BetterCArray!string array;
    if (array[].length != 0) return false;
    if (!(array ~= "") || !(array ~= "A") || !(array ~= "Hello"))
        return false;
    auto tail = array[1 .. $];
    if (tail.length != 2 || tail[0].length != 1 ||
        tail[0][0] != 'A' || tail[1].length != 5) return false;
    // Replace a string slice descriptor; character data is still borrowed.
    tail[0] = "changed";
    auto value = array.get(1);
    if (value.length != 7 || value[0] != 'c') return false;
    return array[0 .. 1][0].length == 0 &&
        array[$ .. $].length == 0;
}

__gshared BetterCArray!int numbers;

int testNumArray() {
    if (!checkIntEdgeCases() || !checkIntSlices()) return 0;
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
    if (!checkStringEdgeCases() || !checkStringSlices()) return 0;
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