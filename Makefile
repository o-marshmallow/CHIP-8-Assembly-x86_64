CC=gcc
CFLAGS= -Wall -g -lSDL2
BIN=chip8
ASMF=machine.s main.s window.s render.s cpu.s cpu_8_opcode.s

all:
	$(CC) $(ASMF) -o $(BIN) $(CFLAGS)
