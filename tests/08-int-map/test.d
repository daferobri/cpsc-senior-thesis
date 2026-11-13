module test;

import betterc_int_map : IntMap;
import betterc_quadratic_int_map : QuadraticIntMap;

// Return the failing source line rather than relying on D runtime assertions.
private int testEmpty(Map)() {
    Map map;
    int value = 123;
    if (map.length() != 0) return __LINE__;
    foreach (key; [0, 1, -1, int.min, int.max]) {
        if (map.get(key, value)) return __LINE__;
        if (value != 123) return __LINE__;
    }
    return 0;
}

private int testInsertAndUpdate(Map)() {
    Map map;
    int value;
    if (!map.put(27, 42)) return __LINE__;
    if (map.length() != 1) return __LINE__;
    if (!map.get(27, value) || value != 42) return __LINE__;
    if (!map.put(27, -99)) return __LINE__;
    if (map.length() != 1) return __LINE__;
    if (!map.get(27, value) || value != -99) return __LINE__;
    value = 123;
    if (map.get(28, value) || value != 123) return __LINE__;
    return 0;
}

private int testIntegerLimits(Map)() {
    Map map;
    int[5] keys = [0, -1, int.min, int.max, 1];
    int[5] values = [0, int.min, int.max, -1, 1];
    foreach (i, key; keys)
        if (!map.put(key, values[i])) return __LINE__;
    if (map.length() != keys.length) return __LINE__;
    foreach (i, key; keys) {
        int value = 123;
        if (!map.get(key, value) || value != values[i]) return __LINE__;
    }
    return 0;
}

private int testCollisionsAndWraparound(Map)() {
    Map map;
    // Initial capacity is 16: these all hash to slot 15 and wrap past slot 0.
    foreach (i; 0 .. 10)
        if (!map.put(15 + i * 16, i * 3)) return __LINE__;
    foreach (i; 0 .. 10) {
        int value;
        if (!map.get(15 + i * 16, value) || value != i * 3) return __LINE__;
    }
    if (!map.put(15 + 5 * 16, 999)) return __LINE__;
    if (map.length() != 10) return __LINE__;
    int value;
    if (!map.get(15 + 5 * 16, value) || value != 999) return __LINE__;
    value = 123;
    if (map.get(15 + 10 * 16, value) || value != 123) return __LINE__;
    return 0;
}

private int testGrowth(Map)() {
    Map map;
    // Verify every existing entry after each insert across multiple growths.
    foreach (i; 0 .. 300) {
        int key = (i - 150) * 16;
        if (!map.put(key, i * 7)) return __LINE__;
        if (map.length() != i + 1) return __LINE__;
        foreach (j; 0 .. i + 1) {
            int value;
            if (!map.get((j - 150) * 16, value) || value != j * 7)
                return __LINE__;
        }
    }
    foreach (i; 0 .. 300)
        if (!map.put((i - 150) * 16, -i)) return __LINE__;
    if (map.length() != 300) return __LINE__;
    foreach (i; 0 .. 300) {
        int value;
        if (!map.get((i - 150) * 16, value) || value != -i) return __LINE__;
    }
    int value = 123;
    if (map.get(999999, value) || value != 123) return __LINE__;
    return 0;
}

private int testFreeAndReuse(Map)() {
    Map map;
    map.freeMemory();
    map.freeMemory();
    if (!map.put(7, 42)) return __LINE__;
    map.freeMemory();
    if (map.length() != 0) return __LINE__;
    int value = 123;
    if (map.get(7, value) || value != 123) return __LINE__;
    if (!map.put(8, 99)) return __LINE__;
    if (map.length() != 1) return __LINE__;
    if (!map.get(8, value) || value != 99) return __LINE__;
    map.freeMemory();
    map.freeMemory(); // Scope exit also frees the already-cleared map.
    return 0;
}

private int runTests(Map)(int testId) {
    switch (testId) {
        case 0: return testEmpty!Map();
        case 1: return testInsertAndUpdate!Map();
        case 2: return testIntegerLimits!Map();
        case 3: return testCollisionsAndWraparound!Map();
        case 4: return testGrowth!Map();
        case 5: return testFreeAndReuse!Map();
        default: return -1;
    }
}

// Keep the existing build.sh export; IDs 0..5 are linear, 6..11 quadratic.
extern(C) int testInsertAndFind(int testId) {
    if (testId >= 0 && testId < 6)
        return runTests!IntMap(testId);
    if (testId >= 6 && testId < 12)
        return runTests!QuadraticIntMap(testId - 6);
    return -1;
}
