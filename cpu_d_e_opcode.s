        ## This file contains routine for CHIP-8 instructions starting with
        ## nibble D or E. The opcode is contained in rax.
        .intel_syntax
        .globl opcode_e
        .globl opcode_d
        .include "macros.s"
        .text

keyindex: # Static and constant data
        .byte 39, 30, 31, 32, 33, 34, 35, 36, 37, 38, 4, 5, 6, 7, 8, 9 
        
        ## Routine from converting 0-9 and A-F values to an SDL key state array
        ## index. These values were taken from SDL2/SDL_scancode.h file.
get_key_index:
        ## RAX contains the key value
        lea %rsi, keyindex
        add %rsi, %rdi
        xor %rax, %rax
        mov %al, BYTE PTR [%rsi]
        ret

        
        ## Opcode for inputs, only RAX is used here
opcode_e:
        push %r12       # R12+ are callee-saved registers
        mov %r12, %rax  # Put instruction in R12
        
        # Store Vx value in RCX
        LOAD_VX

        # Check Vx value (must be < 0x10)
        cmp %rcx, 0x10
        jge ret_opE

        # Store Vx index in RCX
        mov %rdi, %rcx
        call get_key_index
        mov %rcx, %rax
        
        # Check if key is pressed (using key states array)
        # and store the result in RCX again
        xor %rdi, %rdi  # Pass NULL as first argument
        call SDL_GetKeyboardState
        mov %rcx, [%rax + %rcx]
        
        # Check the instruction
        mov %rax, %r12
        and %rax, 0xFF
        cmp %rax, 0x9E
        jne not_9e

        # EX9E instruction, skip if RCX is NOT zero (key pressed)
        test %rcx, %rcx
        jnz ret_skip
        jmp ret_opE
        
not_9e: cmp %rax, 0xA1
        jne not_a1
        # EXA1 instruction, skip if RCX is zero (key NOT pressed)
        test %rcx, %rcx
        jz ret_skip
        jmp ret_opE
        
not_a1: # Unknown opcode
        mov %rax, %r12  # Get original instruction back
        pop %r12
        jne unknown_opcode
        # Never return
ret_skip:
        inc WORD PTR [pc]
        inc WORD PTR [pc]
ret_opE:
        pop %r12
        ret


        
        ## Shifts r11 register r10 times
shift_r11:
        push %r10
beg_sh: cmp %r10, 0
        je ret_sh
        shr %r11, 1
        dec %r10
        jmp beg_sh
ret_sh: pop %r10
        ret
        
opcode_d:
        push %rbx
        push %r9
        push %r10
        push %r11
        push %rax
        xor %r9, %r9
        mov %r9w, WORD PTR [ireg] 
        lea %r9, [ram+%r9]     # r9 = ram+I
        LOAD_Vy
        mov %rbx, %rdx          # Vy in rbx
        LOAD_Vx
        mov %rax, %rcx          # Vx in rax
        mov %rcx, [%rsp]
        and %rcx, 0xF           # N in rcx
        xor %rdi, %rdi          # i in rdi
for1:   cmp %rdi, %rcx
        je return
        ## Load byte from ram
        xor %r8, %r8            # byte in r8
        mov %r8b, BYTE PTR [%r9+%rdi]
        xor %rsi, %rsi          # j in rsi
for2:   cmp %rsi, 8
        je inci
        ## Body of the loop
        mov %r10, 7             # "bit" variable in r11
        sub %r10, %rsi
        mov %r11, %r8
        call shift_r11
        and %r11, 0x1           # r11 contains (b >> (7 - j) & 1)
        jz next
        ## Bit is 1 so we have to check the screen now
        mov %r10, %rbx
        add %r10, %rdi
        imul %r10, 64
        add %r10, %rax
        add %r10, %rsi          # r10 contains (y+i)*64+x+j
        lea %r11, screen
        add %r11, %r10          # r11 contains &screen[y+i][x+j]
        xor %r10, %r10
        mov %r10b, BYTE PTR [%r11] # r10 = screen[y+i][x+j]
        cmp %r10, 0
        je noset
        mov BYTE PTR [regs+0xF], 1
noset:  xor %r10, 1
        mov BYTE PTR [%r11], %r10b
        ## Bit is 0 so we have nothing to change on the screen
next:   ## End of loop body
        inc %rsi
        jmp for2
inci:   inc %rdi
        jmp for1
return: pop %rax
        pop %r11
        pop %r10
        pop %r9
        pop %rbx
        ret
