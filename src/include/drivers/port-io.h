#ifndef ASSEMBLY_H
#define ASSEMBLY_H

void write_byte_to_port(unsigned short port, unsigned char byte);
unsigned char read_byte_from_port(unsigned short port);
void write_word_to_port(unsigned short port, unsigned char word);
unsigned char read_word_from_port(unsigned short port);

#endif