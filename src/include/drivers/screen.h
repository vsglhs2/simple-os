#ifndef SCREEN_H
#define SCREEN_H

void print_char_at(char symbol, int row, int col, char attributes);
void print_string_at(char *string, int row, int col);
void print_string(char *string);
void clear_screen();

#endif