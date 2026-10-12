extern(C):

// A small memory pool for experimentation
__gshared ubyte[4096] memoryPool;
__gshared size_t offset = 0;

void* allocate(size_t bytes) {
    size_t alignment = 8;
    size_t aligned = (offset + alignment - 1)
                   & ~(alignment - 1);

    if (aligned > memoryPool.length ||
        bytes > memoryPool.length - aligned) {
        return null;
    }

    void* ptr = &memoryPool[aligned];
    offset = aligned + bytes;

    return ptr;
}

struct IntArray {
    int* data;
    size_t length;
    size_t capacity;

    void push(int value) {
        if (length >= capacity) {
            size_t newCapacity =
                capacity == 0 ? 4 : capacity * 2;

            int* newData = cast(int*)
                allocate(newCapacity * int.sizeof);

            if (newData is null)
                return;

            for (size_t i = 0; i < length; i++) {
                newData[i] = data[i];
            }

            data = newData;
            capacity = newCapacity;
        }

        data[length] = value;
        length++;
    }
}

__gshared IntArray numbers;

void testArray() {
    numbers.push(10);
    numbers.push(20);
    numbers.push(30);
}

int getElement(int index) {
    if (index < 0 ||
        cast(size_t) index >= numbers.length)
        return -1;

    return numbers.data[index];
}

int getLength() {
    return cast(int) numbers.length;
}