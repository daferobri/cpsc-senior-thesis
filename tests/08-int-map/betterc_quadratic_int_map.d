module betterc_quadratic_int_map;

import core.stdc.stdlib : calloc, free;

// Open addressing - quadratic probing integer map
struct QuadraticIntMap {
    private struct Entry {
        bool occupied;
        int key;
        int value;
    }

    private Entry* entries;
    private size_t capacity;
    private size_t count;

    // The map owns its buffer. Pass it by ref.
    @disable this(this);

    // Identity hash - proof of concept
    private static uint hashInt(int key) {
        return cast(uint) key;
    }

    // Triangular offsets visit every slot because capacity is a power of two.
    // The table always has an empty slot.
    private static size_t findSlot(const(Entry)* table, size_t capacity, int key) {
        size_t index = hashInt(key) % capacity;
        size_t step = 1;
        while (table[index].occupied && table[index].key != key) {
            index = (index + step) % capacity;
            ++step;
        }
        return index;
    }

    private bool grow() {
        if (capacity > size_t.max / Entry.sizeof / 2)
            return false;

        size_t newCapacity = capacity == 0 ? 16 : capacity * 2;
        auto newEntries = cast(Entry*) calloc(newCapacity, Entry.sizeof);
        if (newEntries is null)
            return false;

        foreach (i; 0 .. capacity) {
            if (entries[i].occupied) {
                size_t index = findSlot(newEntries, newCapacity, entries[i].key);
                newEntries[index] = entries[i];
            }
        }

        free(entries);
        entries = newEntries;
        capacity = newCapacity;
        return true;
    }

    // Returns false if allocation fails. Existing entries stay intact.
    bool put(int key, int value) {
        if (capacity == 0 && !grow())
            return false;

        size_t index = findSlot(entries, capacity, key);
        if (!entries[index].occupied) {
            // Grow before inserting a new key past 50% load.
            if (count >= capacity / 2) {
                if (!grow())
                    return false;
                index = findSlot(entries, capacity, key);
            }
            entries[index].key = key;
            entries[index].occupied = true;
            ++count;
        }

        entries[index].value = value;
        return true;
    }

    // Returns false for a missing key. In that case value stays unchanged.
    bool get(int key, ref int value) const {
        if (capacity == 0)
            return false;

        size_t index = findSlot(entries, capacity, key);
        if (!entries[index].occupied)
            return false;

        value = entries[index].value;
        return true;
    }

    size_t length() const {
        return count;
    }

    void freeMemory() {
        free(entries);
        entries = null;
        capacity = 0;
        count = 0;
    }

    ~this() {
        freeMemory();
    }
}
