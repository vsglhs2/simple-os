#include "../include/drivers/screen.h"
#include "../include/drivers/port-io.h"
#include "../include/kernel/utils.h"

#define VIDEO_MEMORY_ADDRESS (char *) 0xb8000

#define MAX_ROWS 25
#define MAX_COLS 80
#define CELL_SIZE 2

#define WHITE_ON_BLACK_BYTE 0x0f
#define EMPTY_BYTE 0x00

#define SCREEN_CONTROL_REGISTER 0x3D4
#define SCREEN_DATA_REGISTER 0x3D5

#define CURSOR_HIGH_BYTE_REGISTER 14
#define CURSOR_LOW_BYTE_REGISTER 15

int get_high_byte(int number) {
    return number >> 8;
}

int to_high_byte(int number) {
    return number << 8;
}

int get_low_byte(int number) {
    return number & 0x00ff;
}

int to_low_byte(int number) {
    return number;
}

int get_cursor_offset() {
    int offset = 0;

    write_byte_to_port(SCREEN_CONTROL_REGISTER, CURSOR_HIGH_BYTE_REGISTER);
    int high_number = read_byte_from_port(SCREEN_DATA_REGISTER);
    offset += to_high_byte(high_number);

    write_byte_to_port(SCREEN_CONTROL_REGISTER, CURSOR_LOW_BYTE_REGISTER);
    int low_number = read_byte_from_port(SCREEN_DATA_REGISTER);
    offset += to_low_byte(low_number);

    return offset * CELL_SIZE;
}

void set_cursor_offset(int offset) {
    write_byte_to_port(SCREEN_CONTROL_REGISTER, CURSOR_HIGH_BYTE_REGISTER);
    int high_byte = get_high_byte(offset);
    write_byte_to_port(SCREEN_DATA_REGISTER, high_byte);

    write_byte_to_port(SCREEN_CONTROL_REGISTER, CURSOR_LOW_BYTE_REGISTER);
    int low_byte = get_low_byte(offset);
    write_byte_to_port(SCREEN_DATA_REGISTER, low_byte);
}

int get_position_offset(int row, int col) {
    return (col + row * MAX_COLS) * CELL_SIZE;
}

char *get_video_memory_offset_pointer(int offset) {
    return VIDEO_MEMORY_ADDRESS + offset;
}

int handle_scroll(int offset) {
    int max_offset = get_position_offset(MAX_ROWS - 1, MAX_COLS - 1);
    if (offset <= max_offset) return offset;

    int row_size = get_position_offset(1, 0);

    for (int i = 1; i < MAX_ROWS; i++) {
        int previous_row_offset = get_position_offset(i - 1, 0);
        char *previous_row_pointer = get_video_memory_offset_pointer(previous_row_offset);

        int next_row_offset = get_position_offset(i, 0);
        char *next_row_pointer = get_video_memory_offset_pointer(next_row_offset);

        copy_memory(next_row_pointer, previous_row_pointer, row_size);
    }

    int last_row_offset = get_position_offset(MAX_ROWS - 1, 0);
    char *last_row_pointer = get_video_memory_offset_pointer(last_row_offset);

    for (int i = 0; i < MAX_COLS; i++) {
        *(last_row_pointer + i) = EMPTY_BYTE;
    }

    return offset - row_size;
}

_Bool is_in_boundaries(int row, int col) {
    return (
        row > 0 &&
        col > 0 &&
        row < MAX_ROWS &&
        col < MAX_COLS
    );
}

void print_char_at(char symbol, int row, int col, char attributes) {
    if (attributes == EMPTY_BYTE) {
        attributes = WHITE_ON_BLACK_BYTE;
    }

    int offset = is_in_boundaries(row, col) ? (
        get_position_offset(row, col)
    ) : (
        get_cursor_offset()
    );
    char *pointer = get_video_memory_offset_pointer(offset);

    if (symbol == '\n') {
        offset = get_position_offset(row + 1, 0);
    } else {
        *(pointer) = symbol;
        *(pointer + 1) = attributes;

        if (col + 1 == MAX_COLS) {
            col = 0;
            row += 1;
        }
        offset = get_position_offset(row, col + 1);
    }

    offset = handle_scroll(offset);
    set_cursor_offset(offset);
}

void print_string_at(char *string, int row, int col) {
    if (is_in_boundaries(row, col)) {
        int offset = get_position_offset(row, col);
        set_cursor_offset(offset);
    }

    int i = 0;
    while (string[i] != EMPTY_BYTE) {
        print_char_at(string[i], row, col, WHITE_ON_BLACK_BYTE);
    }
}

void print_string(char *string) {
    print_string_at(string, -1, -1);
}

void clear_screen() {
    for (int row = 0; row < MAX_ROWS; row++) {
        for (int col = 0; col < MAX_COLS; col++) {
            print_char_at(0x00, row, col, WHITE_ON_BLACK_BYTE);
        }
    }

    int offset = get_position_offset(0, 0);
    set_cursor_offset(offset);
}
