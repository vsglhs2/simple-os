void copy_memory(char *source, char *target, int size) {
    for (int i = 0; i < size; i++) {
        *(target + i) = *(source + i);
    }
}