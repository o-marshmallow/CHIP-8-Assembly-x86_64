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
        ADDR_Vx                 # &Vx in rcx
        mov %dl, BYTE PTR [dt]
        mov BYTE PTR [%rcx], %dl
        ret
        
op_0a:  cmp %r8b, 0x0A
        jne op_15
        ## LD Vx, K
        ## TODO: Wait for key
        ADDR_Vx                 # &Vx in rcx
        mov %dl, 0
        mov BYTE PTR [%rcx], %dl
        ret
 
op_15:  cmp %r8b, 0x15
        jne op_18
        ## LD DT, Vx
        LOAD_Vx                 # Vx in rcx
        mov BYTE PTR [dt], %cl
        ret
        
op_18:  cmp %r8b, 0x18
        jne op_1e
        ## LD ST, Vx
        LOAD_Vx                 # Vx in rcx
        mov BYTE PTR [st], %cl
        ret
        
op_1e:  cmp %r8b, 0x1e
        jne op_29
        ## ADD I, Vx
        LOAD_Vx                 # Vx in rcx
        xor %rdx, %rdx
        mov %dx, WORD PTR [ireg]
        add %rdx, %rcx
        mov WORD PTR [ireg], %dx
        ret
        
op_29:  cmp %r8b, 0x29
        jne op_33
        ## LD F, Vx
        LOAD_Vx                 # Vx in rcx
        imul %rcx, 5
        mov WORD PTR [ireg], %cx
        ret
        
op_33:  cmp %r8b, 0x33
        jne op_55
        ## LD B, Vx
        LOAD_Vx                 # Vx in rcx
        push %rax
        ## Rdx will store the I address
        xor %rdx, %rdx
        mov %dx, WORD PTR [ireg] # I in rdx
        ## Ax will store Vx
        xor %rax, %rax
        mov %ax, %cx
        mov %sil, 100
        div %sil                # Vx/100 in AL, Vx%100 in AH
        mov [ram+%rdx], %al     # Ram[ireg]   = Vx/100
        inc %rdx                # ireg++
        mov %al, %ah
        xor %ah, %ah            # 0xXXYY becomes 0x00XX (in %ax)
        mov %sil, 10
        div %sil                # (Vx%100)/10 in AL, (Vx%100)%10 in AH
        mov [ram+%rdx], %al
        inc %rdx
        mov [ram+%rdx], %ah
        pop %rax
        ret
        
op_55:  cmp %r8b, 0x55
        jne op_65
        ## LD [I], Vx
        ADDR_Vx                 # &Vx in rcx
        xor %rsi, %rsi
        mov %si, WORD PTR [ireg] # I in rsi register
        lea %rdx, regs
cmpl:   cmp %rdx, %rcx          # while(rdx <= rcx)
        jg return
        mov %dil, BYTE PTR [%rdx] # rdi <- V_n
        mov BYTE PTR [ram+%rsi], %dil
        inc %rsi
        inc %rdx
        jmp cmpl
        
op_65:  cmp %r8b, 0x65
        jne unknown_opcode
        ## LD Vx, [I]
         ADDR_Vx                 # &Vx in rcx
        xor %rsi, %rsi
        mov %si, WORD PTR [ireg] # I in rsi register
        lea %rdx, regs
cmpl2:  cmp %rdx, %rcx          # while(rdx <= rcx)
        jg return
        mov %dil, BYTE PTR [ram+%rsi]
        mov BYTE PTR [%rdx], %dil # V_n <- rdi (lowest 16 bits)
        inc %rsi
        inc %rdx
        jmp cmpl2
        
return: ret
