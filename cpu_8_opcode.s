        ## This file contains routine for CHIP-8 instructions starting with
        ## nibble 8. The opcode is contained in rax.
        .intel_syntax
        .globl opcode_8
        .globl load_jumptable_8
        .globl opcode_f
        .globl opcode_e
        .globl opcode_d
        .include "macros.s"
        .text
opcode_d:
opcode_e:
opcode_f:
        
opcode_8:
        mov %rcx, %rax
        and %rcx, 0xF
        mov %rcx, [jmptable+%rcx]
        jmp %rcx
ld_8:
        ## LD Vx, Vy
or_8:
        ## OR Vx, Vy
and_8:
        ## AND Vx, Vy
xor_8:
        ## XOR Vx, Vy
add_8:
        ## ADD Vx, Vy
sub_8:
        ## SUB Vx, Vy
shr_8:
        ## SHR Vx
subn_8:
        ## SUBN Vx, Vy
shl_8:
        ## SHL Vx, Vy
        ret


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
