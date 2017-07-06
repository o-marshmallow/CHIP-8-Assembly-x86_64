        ## This file defines the routine that draws rectangle on the screen
        ## depending on the screen state in the virtual machine
        .intel_syntax
        .set PIXEL_SIZE , 10
        .globl render_screen
        .text
render_screen:
        ## RDI contains a pointer to the renderer
        push %rbp
        mov %rbp, %rsp

        ## Loop on the screen info
        xor %rsi, %rsi          # i
line:   cmp %rsi, 32            # 32 lines
        je return
        xor %rdx, %rdx          # j
col:    cmp %rdx, 64            # 64 columns
        je nextline

        ## Get index of the current cell
        mov %rcx, %rsi          # cell = i*64 + j
        imul %rcx, 64
        add %rcx, %rdx
        mov %cl, BYTE PTR [screen+%rcx]
        cmp %cl, 1
        jne nodraw

        mov %rcx, %rdx
        imul %rcx, PIXEL_SIZE   # X = j*10
        mov DWORD PTR [x], %ecx
        mov %rcx, %rsi
        imul %rcx, PIXEL_SIZE   # Y = i*10
        mov DWORD PTR [y], %ecx

        push %rdi
        push %rsi
        push %rdx
        
        lea %rsi, x             # Load rectangle address
        call fill_rect
        
        pop %rdx
        pop %rsi
        pop %rdi
        
nodraw: 
        inc %rdx
        jmp col
nextline:
        inc %rsi
        jmp line
        
return: pop %rbp
        ret


fill_rect:
        push %rbp
        mov %rbp, %rsp
        
        xor %rsi, %rsi          # i
rline:  cmp %rsi, PIXEL_SIZE    # 10 lines
        je return_pixel
        xor %rdx, %rdx          # j
rcol:   cmp %rdx, PIXEL_SIZE    # 10 columns
        je nextline_pixel

        push %rdi
        push %rsi
        push %rdx

        ## X in rsi
        ## Y in rdx
        push %rsi
        
        mov %esi, DWORD PTR [x]
        add %rsi, %rdx
        
        pop %rdx
        add %edx, DWORD PTR [y]
        
        call SDL_RenderDrawPoint
        
        pop %rdx
        pop %rsi
        pop %rdi
        
nodraw_pixel: 
        inc %rdx
        jmp rcol
nextline_pixel:
        inc %rsi
        jmp rline
        
return_pixel:
        pop %rbp
        ret
        
        .data
x:      .int 0                  # x
y:      .int 0                  # y
