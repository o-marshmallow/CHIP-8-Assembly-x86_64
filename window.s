        .intel_syntax
        .globl window_loop
        .set SDL_INIT_VIDEO, 0x20
        .set WIDTH, 640         # 64 blocs of 10 pixels each
        .set HEIGHT, 320
        .macro SET_COLOR code
        xor %rax, %rax
        mov %rdi, %r13
        mov %rsi, \code
        mov %rdx, \code
        mov %rcx, \code
        mov %r8,  0xFF
        call SDL_SetRenderDrawColor
        .endm
        .text
	
window_loop:
	## Init the video driver
	mov %rdi, SDL_INIT_VIDEO
	call SDL_Init
        ## Window will be stored in rsp, whereas renderer is in rsp+8
        sub %rsp, 16
	xor %rax, %rax
        mov %rdi, WIDTH
        mov %rsi, HEIGHT
        xor %rdx, %rdx
        lea %rcx, [%rsp]
        lea %r8 , [%rsp+8] 
        call SDL_CreateWindowAndRenderer
        ## Store Window in R12 and Renderer in R13
        ## As their address is not needed anymore
        mov %r12, [%rsp]
        mov %r13, [%rsp+8]
        ## Test whether window is null or not
        cmp %r12, 0
        je error
        ## Set color to white
        SET_COLOR 0xFF

        ## Init the CPU and main loop
        call load_jumptable
        mov WORD PTR [pc], 0x200
        mov BYTE PTR [sp], 0xF
begin:
        ## Test events
        xor %rax, %rax
        lea %rdi, event
        call SDL_PollEvent
        cmp %rax, 0
        je endevt
        ## Event.type is a 32-bit value
        xor %rax, %rax
        mov %eax, [event]
        cmp %eax, 256           # SDL_QUIT = 256
        je  dtroy               # if SDL_QUIT, break the loop
endevt:
        ## Execute an instruction of the CHIP-8 machine
        call execute_cpu
        ## Should clean the screen here first with SDL_RenderClear
        SET_COLOR 0x00
        call SDL_RenderClear
        SET_COLOR 0xFF
        ## Draw rectangles depending on the screen informations
        mov %rdi, %r13
        call render_screen
        ## Render window
        mov %rdi, %r13
        call SDL_RenderPresent
        #mov %rdi, 5000
        #call SDL_Delay
        jmp begin
        
        ## Destroy
dtroy:  xor %rax, %rax
        mov %rdi, %r12
        call SDL_DestroyWindow
        call SDL_Quit
return: add %rsp, 16
        ret

error:  xor %rax, %rax
        lea %rdi, winerr
        call printf
        jmp return

        .data
winerr: .asciz "Could not create window\n"

        .bss
event:  .space 64               # Sizeof(SDL_Event) = 56
        
        
