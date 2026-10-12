extern (C):

__gshared ubyte[65_536] memoryPool;
__gshared size_t offset = 0;

void* allocate(size_t bytes) {
    enum size_t alignment = 16;

    size_t aligned = (offset + alignment - 1)
        & ~(alignment - 1);

    if (aligned > memoryPool.length ||
        bytes > memoryPool.length - aligned)
        return null;

    void* ptr = &memoryPool[aligned];
    offset = aligned + bytes;
    return ptr;
}

struct BetterCArray(T) {
    private T* data;
    private size_t _length;
    private size_t capacity;

    bool push(T element) {
        if (_length >= capacity) {
            size_t newCapacity =
                capacity == 0 ? 4 : capacity * 2;

            if (newCapacity < capacity ||
                newCapacity > size_t.max / T.sizeof)
                return false;

            T* newData = cast(T*)
            allocate(newCapacity * T.sizeof);

            if (newData is null)
                return false;

            for (size_t i = 0; i < _length; i++) {
                newData[i] = data[i];
            }

            data = newData;
            capacity = newCapacity;
        }

        data[_length] = element;
        _length++;
        return true;
    }

    bool opOpAssign(string op)(T element) if (op == "~") {
        return push(element);
    }

    size_t length() const {
        return _length;
    }

    T get(size_t index) const {
        return data[index];
    }
}

__gshared BetterCArray!int numbers;

int testArray() {
    if (!(numbers ~= 10))
        return 0;
    if (!(numbers ~= 20))
        return 0;
    if (!(numbers ~= 30))
        return 0;

    return 1;
}

int getElement(int index) {
    if (index < 0 ||
        cast(size_t) index >= numbers.length())
        return -1;

    return numbers.get(cast(size_t) index);
}

int getLength() {
    return cast(int) numbers.length();
}
