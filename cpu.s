        ## This file contains the routines emulating the CHIP-8 CPU
        .intel_syntax
        .globl execute_cpu
        .globl load_jumptable
        .set PTR_SIZE, 8
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
        jmp %rsi
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
        ## Put PC onto the stack
        mov WORD PTR [%rdx], %cx
        ## Change the PC and finish this instruction
        and %rax, 0x0FFF        # Rax contains the address to jump to
        mov WORD PTR [pc], %ax  # Jump the machine to (instr & 0xFFF)
        jmp return
OP3:
        ## 3xkk - SE Vx, byte
        ## rcx contains x then Vx
        mov %rcx, %rax
        shr %rcx, 8
        and %rcx, 0xF
        lea %rdx, regs
        add %rdx, %rcx
        xor %rcx, %rcx
        mov %cl, BYTE PTR [%rdx]
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
        jmp inc_and_return
OP5:
        ## SE Vx, Vy
        jmp inc_and_return
OP6:
        ## LD Vx, byte
        jmp inc_and_return
OP7:
        ## ADD Vx, byte
        jmp inc_and_return
OP8:
        ## 8xy- Instructions
        jmp inc_and_return
OP9:
        ## SNE Vx, Vy
        jmp inc_and_return
OPA:
        ##  LD I, addr
        jmp inc_and_return
OPB:
        ##  JP V0, addr
        jmp inc_and_return
OPC:
        ## RND Vx, byte
        jmp inc_and_return
OPD:
        ## DRW Vx, Vy, nibble
        jmp inc_and_return
OPE:
        ## Ex-- instructions
        jmp inc_and_return
OPF:
        ## Fx-- instructions

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
        add %rax, WORD PTR [pc]
        mov %ah, BYTE PTR [%rax]
        ## Load ram[pc+1] into al
        lea %rbx, [ram]
        add %rbx, WORD PTR [pc]
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
        ## This table contains 0xF (16) 64-bit address
        ## Cell i contains the address of the code executing
        ## instructions starting with i
        ## Example: instruction 00E0 will be executed by the code
        ## located at the address contained in the 0 indexed cell
        .space (0xF*PTR_SIZE)

s_unknown:
        .asciz "Unknown opcode %04X\nExiting now...\n"
