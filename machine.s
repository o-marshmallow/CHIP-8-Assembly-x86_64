        .globl ram
        .globl regs
        .globl pc
        .globl sp
        .globl stack
        .globl screen
        
        .data
ram:    .byte 0xF0,0x90,0x90,0x90,0xF0,0x20,0x60,0x20
        .byte 0x20,0x70,0xF0,0x10,0xF0,0x80,0xF0,0xF0
        .byte 0x10,0xF0,0x10,0xF0,0x90,0x90,0xF0,0x10
        .byte 0x10,0xF0,0x80,0xF0,0x10,0xF0,0xF0,0x80
        .byte 0xF0,0x90,0xF0,0xF0,0x10,0x20,0x40,0x40
        .byte 0xF0,0x90,0xF0,0x90,0xF0,0xF0,0x90,0xF0
        .byte 0x10,0xF0,0xF0,0x90,0xF0,0x90,0x90,0xE0
        .byte 0x90,0xE0,0x90,0xE0,0xF0,0x80,0x80,0x80
        .byte 0xF0,0xE0,0x90,0x90,0x90,0xE0,0xF0,0x80
        .byte 0xF0,0x80,0xF0,0xF0,0x80,0xF0,0x80,0x80
        .space (0xFFF-80)

        .bss
regs:   .space 0xF
pc:     .space 2
sp:     .space 1
stack:  .space 0xF*2            # Stack is 16 16-bit array
screen: .space 64*32            # Screen size is 64*32 pixels
