import core.stdc.stdlib : malloc, realloc, free;

extern (C):

struct BetterCArray(T) {
    private T* data;
    private size_t _length;
    private size_t capacity;

    // Append an element
    bool push(T element) {
        if (_length >= capacity) {
            size_t newCapacity =
                capacity == 0 ? 4 : capacity * 2;

            // Check for integer overflow
            if (newCapacity < capacity ||
                newCapacity > size_t.max / T.sizeof)
                return false;

            // Allocate or resize memory
            T* newData = cast(T*) realloc(
                data,
                newCapacity * T.sizeof
            );

            if (newData is null)
                return false;

            data = newData;
            capacity = newCapacity;
        }

        data[_length] = element;
        _length++;
        return true;
    }

    // Get the number of elements
    size_t length() const {
        return _length;
    }

    // Get an element by index
    T get(size_t index) const {
        return data[index];
    }

    bool isEmpty() const {
        return data is null;
    }

    size_t getCapacity() const {
        return capacity;
    }

    // Release allocated memory
    void freeMemory() {
        if (data !is null) {
            free(data);
        }

        data = null;
        _length = 0;
        capacity = 0;
    }
}

__gshared BetterCArray!int numbers;

int testNumArray() {
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