        ## This file contains routine for CHIP-8 instructions starting with
        ## nibble 8. The opcode is contained in rax.
        .intel_syntax
        .globl opcode_8
        .globl load_jumptable_8
        .include "macros.s"
        .text
        
opcode_8:
        mov %rcx, %rax
        and %rcx, 0xF
        mov %rcx, [jmptable+%rcx]
        jmp %rcx
ld_8:
        ## LD Vx, Vy
        ADDR_Vx                 # &Vx in rcx
        LOAD_Vy                 # Vy in rdx
        mov BYTE PTR [%rcx], %dl
        ret
or_8:
        ## OR Vx, Vy
        ADDR_Vx
        mov %rdi, %rcx          # &Vx in rdi
        LOAD_Vx                 # Vx in rcx
        LOAD_Vy                 # Vy in rdx
        or %cl, %dl
        mov BYTE PTR [%rdi], %cl
        ret
and_8:
        ## AND Vx, Vy
        ADDR_Vx
        mov %rdi, %rcx          # &Vx in rdi
        LOAD_Vx                 # Vx in rcx
        LOAD_Vy                 # Vy in rdx
        and %cl, %dl
        mov BYTE PTR [%rdi], %cl
        ret
xor_8:
        ## XOR Vx, Vy
        ADDR_Vx
        mov %rdi, %rcx          # &Vx in rdi
        LOAD_Vx                 # Vx in rcx
        LOAD_Vy                 # Vy in rdx
        xor %cl, %dl
        mov BYTE PTR [%rdi], %cl
        ret
add_8:
        ## ADD Vx, Vy
        ADDR_Vx
        mov %rdi, %rcx          # &Vx in rdi
        LOAD_Vx                 # Vx in rcx
        LOAD_Vy                 # Vy in rdx
        add %cx, %dx
        mov BYTE PTR [%rdi], %cl
        cmp %cx, 0xFF
        jng return
        mov BYTE PTR [regs+0xF], 1
        ret
sub_8:
        ## SUB Vx, Vy
        ADDR_Vx
        mov %rdi, %rcx          # &Vx in rdi
        LOAD_Vx                 #  Vx in rcx
        LOAD_Vy                 #  Vy in rdx
        sub %cx, %dx
        mov BYTE PTR [%rdi], %cl
        cmp %cx, 0
        jge return
        mov BYTE PTR [regs+0xF], 1
        ret
shr_8:
        ## SHR Vx
        LOAD_Vx
        mov %rdx, %rcx          #  Vx in rdx
        ADDR_Vx                 # &Vx in rcx
        mov %rdi, %rdx
        and %rdi, 1             # rdi = Vx & 1
        shr %rdx, 1
        mov BYTE PTR [%rcx], %dl
        cmp %dil, 1
        jne return
        mov BYTE PTR [regs+0xF], 1
        ret
subn_8:
        ## SUBN Vx, Vy
        ADDR_Vx
        mov %rdi, %rcx          # &Vx in rdi
        LOAD_Vx                 #  Vx in rcx
        LOAD_Vy                 #  Vy in rdx
        xchg %rcx, %rdx
        sub %cx, %dx
        mov BYTE PTR [%rdi], %cl
        cmp %cx, 0
        jge return
        mov BYTE PTR [regs+0xF], 1
        ret
shl_8:
        ## SHL Vx, Vy
        LOAD_Vx
        mov %rdx, %rcx          #  Vx in rdx
        ADDR_Vx                 # &Vx in rcx
        mov %rdi, %rdx
        shr %rdi, 7             # rdi = Vx >> 7
        shl %rdx, 1
        mov BYTE PTR [%rcx], %dl
        cmp %dil, 1
        jne return
        mov BYTE PTR [regs+0xF], 1
return: ret


load_jumptable_8:
        push %rbp
        mov %rbp, %rsp
        lea %rax, ld_8
        mov [jmptable], %rax
        lea %rax, or_8
        mov [jmptable+1*PTR_SIZE], %rax
        lea %rax, and_8
        mov [jmptable+2*PTR_SIZE], %rax
        lea %rax, xor_8
        mov [jmptable+3*PTR_SIZE], %rax
        lea %rax, add_8
        mov [jmptable+4*PTR_SIZE], %rax
        lea %rax, sub_8
        mov [jmptable+5*PTR_SIZE], %rax
        lea %rax, shr_8
        mov [jmptable+6*PTR_SIZE], %rax
        lea %rax, subn_8
        mov [jmptable+7*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable+8*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable+9*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable+10*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable+11*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable+12*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable+13*PTR_SIZE], %rax
        lea %rax, shl_8
        mov [jmptable+14*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable+15*PTR_SIZE], %rax
        pop %rbp
        ret
        
        .data
jmptable:
        ## See description of the jumptable in cpu.s
        .space (0xF*PTR_SIZE)
