#include "../include/drivers/port-io.h"

void write_byte_to_port(unsigned short port, unsigned char byte) {
    __asm__("out %%al, %%dx" :: "a" (byte), "d" (port));
}

unsigned char read_byte_from_port(unsigned short port) {
    unsigned char byte;
    __asm__("in %%dx, %%al" : "=a" (byte) : "d" (port));

    return byte;
}

void write_word_to_port(unsigned short port, unsigned char word) {
    __asm__("out %%ax, %%dx" :: "a" (word), "d" (port));
}

unsigned char read_word_from_port(unsigned short port) {
    unsigned char word;
    __asm__("in %%dx, %%ax" : "=a" (word) : "d" (port));

    return word;
}
