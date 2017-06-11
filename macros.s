        .macro ADDR_Vx
        mov %rcx, %rax
        and %rcx, 0x0F00
        shr %rcx, 8
        lea %rcx, [regs+%rcx]
        .endm
        .macro LOAD_Vx
        mov %rcx, %rax
        and %rcx, 0x0F00
        shr %rcx, 8
        mov %cl, BYTE PTR [regs+%rcx]
        and %rcx, 0xFF
        .endm
        .macro LOAD_Vy
        mov %rdx, %rax
        and %rdx, 0x00F0
        shr %rdx, 4
        mov %dl, BYTE PTR [regs+%rdx]
        and %rdx, 0xFF
        .endm
        .set PTR_SIZE, 8
