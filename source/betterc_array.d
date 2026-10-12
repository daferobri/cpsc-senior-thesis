module betterc_array;

import core.stdc.stdlib : realloc, free;

struct BetterCArray(T) {
    private T* data;
    private size_t _length;
    private size_t capacity;

    // Each array owns its buffer; copying would duplicate ownership.
    @disable this(this);

    ~this() {
        freeMemory();
    }

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

    // Append with ~=; returns false if allocation or capacity growth fails.
    bool opOpAssign(string op)(T element)
        if (op == "~")
    {
        return push(element);
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
