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
    # Code for seta20.1 and seta20.2 taken from xv6.
seta20.1:
    inb     $0x64,%al
    testb   $0x2,%al
    jnz     seta20.1
    movb    $0xd1,%al
    outb    %al,$0x64
seta20.2:
    inb     $0x64,%al
    testb   $0x2,%al
    jnz     seta20.2
    movb    $0xdf,%al
    outb    %al,$0x60
    call check_and_enable_a20
    call cmain
    hlt

.section .bss
stack_bottom:
    # Revise the stack size.
    .skip 64
stack_top:
