        ## This file contains routine for CHIP-8 instructions starting with
        ## nibble F. The opcode is contained in rax.
        .intel_syntax
        .globl opcode_f
        .include "macros.s"
        .text

opcode_f:
        ret
