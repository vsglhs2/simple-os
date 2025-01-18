void some_func() {

}

int main() {
    char *VIDEO_MEMORY_POINTER = (char *) 0xb8000;
    *VIDEO_MEMORY_POINTER = 'X';

    some_func();

    return 0;
}
