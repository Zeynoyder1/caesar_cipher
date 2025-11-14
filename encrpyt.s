        .equ    SYS_READ,   63
        .equ    SYS_WRITE,  64
        .equ    SYS_EXIT,   93

        .equ    STDIN,  0
        .equ    STDOUT, 1

        .equ    SHIFT,  3          // change this to set the Caesar shift

        .section .bss
        .align  3
buf:    .skip   2048               // input/output buffer

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

        // x0 = bytes_read
        mov     x19, x0            // save length
        adrp    x20, buf
        add     x20, x20, :lo12:buf

        // process: Caesar shift on letters (encrypt)
        mov     x21, #0            // i = 0
        mov     w22, #SHIFT        // w22 = shift

loop:
        cmp     x21, x19
        b.ge    done_process

        // load byte b = buf[i]
        ldrb    w0, [x20, x21]

        // if 'A'<=b<='Z'
        mov     w1, w0
        cmp     w1, #'A'
        b.lt    check_lower
        cmp     w1, #'Z'
        b.gt    check_lower
        // uppercase mapping
        sub     w1, w1, #'A'           // 0..25
        add     w1, w1, w22            // +shift
        mov     w3, #26
        cmp     w1, w3
        b.lt    u_store
        sub     w1, w1, w3
u_store:
        add     w1, w1, #'A'
        b       store

check_lower:
        // if 'a'<=b<='z'
        mov     w1, w0
        cmp     w1, #'a'
        b.lt    store_orig
        cmp     w1, #'z'
        b.gt    store_orig
        // lowercase mapping
        sub     w1, w1, #'a'
        add     w1, w1, w22
        mov     w3, #26
        cmp     w1, w3
        b.lt    l_store
        sub     w1, w1, w3
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
        // write buf back out
        mov     x0, #STDOUT
        adrp    x1, buf
        add     x1, x1, :lo12:buf
        mov     x2, x19
        mov     x8, #SYS_WRITE
        svc     #0

        // exit(0)
        mov     x0, #0
        mov     x8, #SYS_EXIT
        svc     #0
