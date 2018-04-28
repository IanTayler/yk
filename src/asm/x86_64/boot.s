.section .multiboot
header_start:
    .int 0xe85250d6
    .int 0
    .int header_end - header_start

    # Checksum
    .int 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    .word 0
    .word 0
    .int 8
header_end:

.global start
.extern check_and_enable_a20
.extern check_a20
.extern __spitredchar
.extern cmain

.section .text
start:
    # Set up the stack
    movl stack_top, %esp
    # enable A20
    call check_and_enable_a20
    call cmain
    hlt

.section .bss
stack_bottom:
    # Revise the stack size.
    .skip 64
stack_top:
