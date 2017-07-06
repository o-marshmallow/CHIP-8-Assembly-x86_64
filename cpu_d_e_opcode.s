        ## This file contains routine for CHIP-8 instructions starting with
        ## nibble D or E. The opcode is contained in rax.
        .intel_syntax
        .globl opcode_e
        .globl opcode_d
        .include "macros.s"
        .text

        ## Controls are not working for the moment
opcode_e: ret

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
        LOAD_Vx
        mov %rax, %rcx          # Vx in rax
        LOAD_Vy
        mov %rbx, %rdx          # Vy in rbx
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
