#ifndef _SCREEN_H
#define _SCREEN_H

#ifndef __ASSEMBLER__
#include "system.h"

typedef struct {
	unsigned int begin_y, begin_x;
	unsigned int rows, cols;
} rect_t;

void set_color(uint8_t fgcolor, uint8_t bgcolor);
void get_color(uint8_t *fgcolor, uint8_t *bgcolor);
void clear_screen();
void set_cursor(uint8_t row, uint8_t col);
void put_char(uint8_t ch);
void puts(char *message);
void put_udecimal(uint32_t n);
void divide(uint32_t dividend, uint32_t divisor, uint32_t *quotient, uint32_t *remainder);
void draw_rect(rect_t *rect);
void fill_rect(rect_t *rect, unsigned char ch);

#endif

#define MAX_ROWS		30
#define MAX_COLS 		80

#define BLACK			0x0
#define BLUE			0x1
#define GREEN			0x2
#define CYAN			0x3
#define RED				0x4
#define MAGENTA			0x5
#define BROWN			0x6
#define WHITE			0x7
#define GRAY			0x8
#define LIGHT_BLUE		0x9
#define LIGHT_GREEN		0xa
#define LIGHT_CYAN		0xb
#define LIGHT_RED		0xc
#define LIGHT_MAGENTA	0xd
#define YELLOW			0xe
#define BRIGHT_WHITE	0xf

#endif
