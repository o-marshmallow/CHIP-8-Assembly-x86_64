CC=gcc
CFLAGS= -Wall -g -lSDL2
BIN=chip8

all:
	$(CC) machine.s main.s window.s render.s cpu.s -o $(BIN) $(CFLAGS)
