        .intel_syntax
        .globl main
        .set SIZE, 8
        .set BUFS, 0x400
        .text

main:      
        cmp %rdi, 2
        jne invalid
        ## Open rom file
        mov %rax, 2
        mov %rdi, [%rsi+SIZE]
        xor %rsi, %rsi          # RD_ONLY = 0
        xor %rdx, %rdx          # Flags are ignored
        syscall
        cmp %rax, 0
        jle readerr
        ## Read the rom file
        ## We assume a rom is not larger than 0x400 (1024) bytes
        mov %rdi, %rax          # File descriptor
        lea %rsi, rdbuff
        mov %rdx, BUFS   
        xor %rax, %rax
        syscall
        cmp %rax, 0
        jl readerr
        ## Put the content in machine RAM at address 0x200
        lea %rdi, [ram+0x200]
        lea %rsi, rdbuff
        mov %rdx, %rax
        xor %rax, %rax
        call memcpy
        ## ROM loaded, we can set up the window
        lea %rdi, loaded
        xor %rax, %rax
        call printf
        call window_loop
        ret
        
        ## Error launching the emulator, invalid arguments on startup
invalid:
        mov %rax, 1
        mov %rdi, 1
        lea %rsi, err
        mov %rdx, 19
        syscall
        ret
        ## Error reading the rom file
readerr:
        xor %rax, %rax
        lea %rdi, read
        call printf
        ret

        .data
err:    .asciz "usage: ./chip8 rom\n"
read:   .asciz "Cannot read file\n"
loaded: .asciz "ROM loaded !\n"

        .bss
rdbuff: .space BUFS
