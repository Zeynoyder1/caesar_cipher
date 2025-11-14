        .equ    SYS_READ,   63
        .equ    SYS_WRITE,  64
        .equ    SYS_EXIT,   93

        .equ    STDIN,  0
        .equ    STDOUT, 1

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
        mov     w22, #13           // fixed ROT13 shift
        mov     w23, #26

loop:
        cmp     x21, x19
        b.ge    done_process

        ldrb    w0, [x20, x21]     // b

        // uppercase?
        mov     w1, w0
        cmp     w1, #'A'
        b.lt    check_lower
        cmp     w1, #'Z'
        b.gt    check_lower

        sub     w1, w1, #'A'       // 0..25
        add     w1, w1, w22        // +13
        cmp     w1, w23
        b.lt    u_store
        sub     w1, w1, w23
u_store:
        add     w1, w1, #'A'
        b       store

check_lower:
        mov     w1, w0
        cmp     w1, #'a'
        b.lt    store_orig
        cmp     w1, #'z'
        b.gt    store_orig

        sub     w1, w1, #'a'
        add     w1, w1, w22        // +13
        cmp     w1, w23
        b.lt    l_store
        sub     w1, w1, w23
l_store:
        add     w1, w1, #'a'
        b       store

store_orig:
        mov     w1, w0

store:
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
