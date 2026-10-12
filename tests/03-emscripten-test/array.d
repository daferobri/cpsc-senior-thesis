import core.stdc.stdlib : malloc, realloc, free;

extern(C):

int testAllocation() {
    int* numbers = cast(int*) malloc(3 * int.sizeof);

    if (numbers is null)
        return -1;

    numbers[0] = 10;
    numbers[1] = 20;
    numbers[2] = 30;

    int result = numbers[0] + numbers[1] + numbers[2];

    free(numbers);
    return result;
}