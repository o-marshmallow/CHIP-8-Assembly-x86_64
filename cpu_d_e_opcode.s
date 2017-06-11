        ## This file contains routine for CHIP-8 instructions starting with
        ## nibble D or E. The opcode is contained in rax.
        .intel_syntax
        .globl opcode_e
        .globl opcode_d
        .include "macros.s"
        .text

opcode_e:
opcode_d:
        ret
