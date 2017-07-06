        ## This file contains the routines emulating the CHIP-8 CPU
        .intel_syntax
        .globl execute_cpu
        .globl load_jumptable
        .globl unknown_opcode
        .include "macros.s"
        .text
execute_cpu:
        push %rbp
        mov %rbp, %rsp
        push %rbx

        ## Get instruction in rax
        call load_instruction
        ## Now that rax contains the opcode, we have to get the first nibble
        mov %rdi, %rax
        shr %rdi, 12
        imul %rdi, PTR_SIZE     # Index of the nibble in the table
        lea %rsi, jmptable
        add %rsi, %rdi          
        mov %rsi, [%rsi]        # rsi = jmptable[nibble] (jmptable as void*)
debug:	jmp %rsi
	## From here, only %rax is used
OP0:    cmp %rax, 0x00E0
        jne RET
        ## CLS
        lea %rdi, screen
        xor %rsi, %rsi
        mov %rdx, 64*32         # Number of integers for screen array
        call memset
	jmp inc_and_return
        
RET:    cmp %rax, 0x00EE
        jne unknown_opcode
        ## RET
        ## Put the address of the return address in rdx
        lea %rdx, stack
        xor %rcx, %rcx
        mov %cl, BYTE PTR [sp]
        imul %rcx, 2
        add %rdx, %rcx
        ## Get return address from rdx and put it into rcx
        xor %rcx, %rcx
        mov %cx, WORD PTR [%rdx]
        ## Load it into PC
        mov WORD PTR [pc], %cx
        ## Then increment SP
        inc BYTE PTR [sp]
        jmp return
OP1:
        ## JP addr
        and %rax, 0x0FFF
        mov WORD PTR [pc], %ax
        jmp return
OP2:
        ## CALL addr
        dec BYTE PTR [sp]       # Decrement StackPointer
        lea %rdx, stack
        xor %rcx, %rcx
        mov %cl, BYTE PTR [sp]  # Load SP in lowest byte of rcx
        imul %rcx, 2            # Size of elements in stack = 2
        add %rdx, %rcx
        ## Load PC into RCX
        xor %rcx, %rcx
        mov %cx, WORD PTR [pc]
        ## Put the NEXT PC onto the stack
	add %cx, 2
        mov WORD PTR [%rdx], %cx
        ## Change the PC and finish this instruction
        and %rax, 0x0FFF        # Rax contains the address to jump to
        mov WORD PTR [pc], %ax  # Jump the machine to (instr & 0xFFF)
        jmp return
OP3:
        ## 3xkk - SE Vx, byte
        ## rcx contains x then Vx
        LOAD_Vx
        ## rdx contains kk
        mov %rdx, %rax
        and %rdx, 0xFF
        ## Compare rcx and rdx
        cmp %rcx, %rdx
        jne inc_and_return
        inc WORD PTR [pc]
        inc WORD PTR [pc]
        jmp inc_and_return
OP4:
        ## SNE Vx, byte
        ## rcx contains x then Vx
        LOAD_Vx
        ## rdx contains kk
        mov %rdx, %rax
        and %rdx, 0xFF
        ## Compare rcx and rdx
        cmp %rcx, %rdx
        je inc_and_return
        inc WORD PTR [pc]
        inc WORD PTR [pc]
        jmp inc_and_return
OP5:
OP9:    
        ## SE/SNE Vx, Vy
        ## Load Vx into rcx
        LOAD_Vx
        ## And Vy into rdx
        LOAD_Vy
        ## Compare Vx and Vy
        mov %rsi, %rax
        shr %rsi, 12
        cmp %rsi, 5             # Test whether the instruction is SE or SNE
        jne case9
        ## SE case
        cmp %rcx, %rdx
        jne inc_and_return
        inc WORD PTR [pc]
        inc WORD PTR [pc]
        jmp inc_and_return
case9:  # SNE case
        cmp %rcx, %rdx
        je inc_and_return
        inc WORD PTR [pc]
        inc WORD PTR [pc]
        jmp inc_and_return
OP6:
        ## LD Vx, byte
        ADDR_Vx
        ## Load kk into rdx
        mov %rdx, %rax
        and %rdx, 0xFF
        ## Store lowest byte into Vx
        mov BYTE PTR [%rcx], %dl
        jmp inc_and_return
OP7:
        ## ADD Vx, byte
        LOAD_Vx
        mov %rdi, %rcx          # rdi contains the value Vx
        ADDR_Vx                 # rcx contains the address of Vx
        ## Load kk into rdx
        mov %rdx, %rax
        and %rdx, 0xFF
        add %dil, %dl            # rdi += rdx
        mov BYTE PTR [%rcx], %dil
        jmp inc_and_return
OP8:
        ## 8xy- Instructions
        call opcode_8
        jmp inc_and_return
OPA:
        ##  LD I, addr
        mov %rcx, %rax
        and %rcx, 0xFFF
        mov WORD PTR [ireg], %cx
        jmp inc_and_return
OPB:
        ##  JP V0, addr
        mov %rcx, %rax
        and %rcx, 0xFFF
        xor %rdx, %rdx
        mov %dl, [regs]
        add %rcx, %rdx
        mov WORD PTR [pc], %cx
        jmp return
OPC:
        ## RND Vx, byte
	rdrand %rdi
        ## Load &Vx and kk
        ADDR_Vx                 
        mov %rdx, %rax
        and %rdx, 0xFF
        add %dl, %dil           # kk += random
        mov BYTE PTR [%rcx], %dl
        jmp inc_and_return
OPD:
        ## DRW Vx, Vy, nibble
        call opcode_d
        jmp inc_and_return
OPE:
        ## Ex-- instructions
        call opcode_e
        jmp inc_and_return
OPF:
        ## Fx-- instructions
        call opcode_f
        
inc_and_return:
        inc WORD PTR [pc]
        inc WORD PTR [pc]
return: 
        pop %rbx
        pop %rbp
        ret

load_instruction:
        ## Load current instruction
        ## Load ram[pc] into ah
        lea %rax, [ram]
        add %ax, WORD PTR [pc]
        mov %ah, BYTE PTR [%rax]
        ## Load ram[pc+1] into al
        lea %rbx, [ram]
        add %bx, WORD PTR [pc]
        inc %rbx
        mov %al, BYTE PTR [%rbx]
        ## Set rax highest bits to 0
        push %ax
        xor %rax, %rax
        pop %ax
        ret

unknown_opcode:
        ## Print the unknown opcode
        lea %rdi, s_unknown
        mov %rsi, %rax
        xor %rax, %rax
        call printf
        ## Exit with code 5
        mov %rax, 60
        mov %rdi, 5
        syscall

load_jumptable:
        push %rbp
        mov %rbp, %rsp

        call load_jumptable_8
        
        ## Load the address in the table
        lea %rax, OP0
        mov [jmptable], %rax
        lea %rax, OP1
        mov [jmptable+1*PTR_SIZE], %rax
        lea %rax, OP2
        mov [jmptable+2*PTR_SIZE], %rax
        lea %rax, OP3
        mov [jmptable+3*PTR_SIZE], %rax
        lea %rax, OP4
        mov [jmptable+4*PTR_SIZE], %rax
        lea %rax, OP5
        mov [jmptable+5*PTR_SIZE], %rax
        lea %rax, OP6
        mov [jmptable+6*PTR_SIZE], %rax
        lea %rax, OP7
        mov [jmptable+7*PTR_SIZE], %rax
        lea %rax, OP8
        mov [jmptable+8*PTR_SIZE], %rax
        lea %rax, OP9
        mov [jmptable+9*PTR_SIZE], %rax
        lea %rax, OPA
        mov [jmptable+10*PTR_SIZE], %rax
        lea %rax, OPB
        mov [jmptable+11*PTR_SIZE], %rax
        lea %rax, OPC
        mov [jmptable+12*PTR_SIZE], %rax
        lea %rax, OPD
        mov [jmptable+13*PTR_SIZE], %rax
        lea %rax, OPE
        mov [jmptable+14*PTR_SIZE], %rax
        lea %rax, OPF
        mov [jmptable+15*PTR_SIZE], %rax
        pop %rbp
        ret
        
        .data
jmptable:
        ## This jump table is used for performance
        ## This table contains 0x10 (16) 64-bit address
        ## Cell i contains the address of the code executing
        ## instructions starting with i
        ## Example: instruction 00E0 will be executed by the code
        ## located at the address contained in the 0 indexed cell
        .space (0x10*PTR_SIZE)

s_unknown:
        .asciz "Unknown opcode %04X\nExiting now...\n"
