        ## This file contains routine for CHIP-8 instructions starting with
        ## nibble F. The opcode is contained in rax.
        .intel_syntax
        .globl opcode_f
        .include "macros.s"
        .text

        ## Opcode is in register rax
opcode_f:
        mov %r8, %rax
        cmp %r8b, 0x07
        jne op_0a
        ## LD Vx, DT
op_0a:  cmp %r8b, 0x0A
        jne op_15
        ## LD Vx, K
op_15:  cmp %r8b, 0x15
        jne op_18
        ## LD DT, Vx
op_18:  cmp %r8b, 0x18
        jne op_1e
        ## LD ST, Vx
op_1e:  cmp %r8b, 0x1e
        jne op_29
        ## ADD I, Vx
op_29:  cmp %r8b, 0x29
        jne op_33
        ## LD F, Vx
op_33:  cmp %r8b, 0x33
        jne op_55
        ## LD B, Vx
op_55:  cmp %r8b, 0x55
        jne op_65
        ## LD [I], Vx
op_65:  cmp %r8b, 0x65
        jne unknown_opcode
        ## LD Vx, [I]

return: ret
