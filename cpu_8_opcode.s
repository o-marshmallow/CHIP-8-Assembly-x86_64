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
        mov %rcx, [jmptable8+%rcx*PTR_SIZE]
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
        add %cl, %dl
        mov BYTE PTR [%rdi], %cl
	## If overflows, write 1
	jo  return_f_1
	jmp return_f_0
sub_8:
        ## SUB Vx, Vy
        ADDR_Vx
        mov %rdi, %rcx          # &Vx in rdi
        LOAD_Vx                 #  Vx in rcx
        LOAD_Vy                 #  Vy in rdx
        sub %cl, %dl
        mov BYTE PTR [%rdi], %cl
        jg  return_f_1
        jmp return_f_0
shr_8:
        ## SHR Vx
        LOAD_Vx
        mov %rdx, %rcx          #  Vx in rdx
        ADDR_Vx                 # &Vx in rcx
        shr %dl, 1
        mov BYTE PTR [%rcx], %dl
        jc  return_f_1
	jmp return_f_0
subn_8:
        ## SUBN Vx, Vy
        ADDR_Vx
        mov %rdi, %rcx          # &Vx in rdi
        LOAD_Vx                 #  Vx in rcx
        LOAD_Vy                 #  Vy in rdx
        xchg %rcx, %rdx
        sub %cl, %dl
        mov BYTE PTR [%rdi], %cl
        jg  return_f_1
        jmp return_f_0	
shl_8:
        ## SHL Vx, Vy
        LOAD_Vx
        mov %rdx, %rcx          #  Vx in rdx
        ADDR_Vx                 # &Vx in rcx
        shl %dl, 1
        mov BYTE PTR [%rcx], %dl
        jc  return_f_1
return_f_0:
        mov BYTE PTR [regs+0xF], 0
	ret
return_f_1:
        mov BYTE PTR [regs+0xF], 1
	ret

load_jumptable_8:
        push %rbp
        mov %rbp, %rsp
        lea %rax, ld_8
        mov [jmptable8], %rax
        lea %rax, or_8
        mov [jmptable8+1*PTR_SIZE], %rax
        lea %rax, and_8
        mov [jmptable8+2*PTR_SIZE], %rax
        lea %rax, xor_8
        mov [jmptable8+3*PTR_SIZE], %rax
        lea %rax, add_8
        mov [jmptable8+4*PTR_SIZE], %rax
        lea %rax, sub_8
        mov [jmptable8+5*PTR_SIZE], %rax
        lea %rax, shr_8
        mov [jmptable8+6*PTR_SIZE], %rax
        lea %rax, subn_8
        mov [jmptable8+7*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable8+8*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable8+9*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable8+10*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable8+11*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable8+12*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable8+13*PTR_SIZE], %rax
        lea %rax, shl_8
        mov [jmptable8+14*PTR_SIZE], %rax
        lea %rax, unknown_opcode
        mov [jmptable8+15*PTR_SIZE], %rax
        pop %rbp
        ret
        
        .data
jmptable8:
        ## See description of the jumptable in cpu.s
        .space (0x10*PTR_SIZE)
