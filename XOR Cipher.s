        .equ    SYS_READ,   63
        .equ    SYS_WRITE,  64
        .equ    SYS_EXIT,   93

        .equ    STDIN,  0
        .equ    STDOUT, 1

        .equ    KEY,    0x2A       // XOR key (change this)

        .section .bss
        .align  3
buf:    .skip   2048

        .section .text
        .global _start

_start:
        // read into buf
        mov     x0, #STDIN
        adrp    x1, buf
        add     x1, x1, :lo12:buf
        mov     x2, #2048
        mov     x8, #SYS_READ
        svc     #0

        mov     x19, x0
        adrp    x20, buf
        add     x20, x20, :lo12:buf

        mov     x21, #0            // i = 0
        mov     w22, #KEY          // XOR key

loop:
        cmp     x21, x19
        b.ge    done_process

        ldrb    w0, [x20, x21]     // b
        eor     w1, w0, w22        // w1 = b ^ KEY
        strb    w1, [x20, x21]

        add     x21, x21, #1
        b       loop

done_process:
        mov     x0, #STDOUT
        adrp    x1, buf
        add     x1, x1, :lo12:buf
        mov     x2, x19
        mov     x8, #SYS_WRITE
        svc     #0

        mov     x0, #0
        mov     x8, #SYS_EXIT
        svc     #0
