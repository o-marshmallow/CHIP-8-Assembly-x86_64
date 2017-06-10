        .intel_syntax
        .globl window
        .set SDL_INIT_VIDEO, 0x20
        .set WIDTH, 640         # 64 blocs of 10 pixels each
        .set HEIGHT, 320
        .text
        
window: push %rbp
        mov %rbp, %rsp
        sub %rsp, 16
        ## Window will be stored in rsp, whereas renderer is in rsp+8
        mov %rdi, WIDTH
        mov %rsi, HEIGHT
        xor %rdx, %rdx
        lea %rcx, [%rsp]
        lea %r8 , [%rsp+8] 
        call SDL_CreateWindowAndRenderer
        ## Store Window in R12 and Renderer in R13
        mov %r12, [%rsp]
        mov %r13, [%rsp+8]
        ## Test whether window is null or not
        cmp %r12, 0
        je error
        ## Set color to white
        xor %rax, %rax
        mov %rdi, %r13
        mov %rsi, 0xFF
        mov %rdx, 0xFF
        mov %rcx, 0xFF
        mov %r8,  0xFF
        call SDL_SetRenderDrawColor

        ## Main loop
begin:  mov %rdi, %r13
        call SDL_RenderPresent
        pause
        jmp begin
        
        ## Destroy and quit SDL
        xor %rax, %rax
        mov %rdi, %r12
        call SDL_DestroyWindow
        call SDL_Quit
return: sub %rsp, 16
        pop %rbp
        ret

error:  xor %rax, %rax
        lea %rdi, winerr
        call printf
        jmp return

        .data
winerr: .asciz "Could not create window\n"
