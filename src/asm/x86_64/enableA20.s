.section .text
.extern __spitredchar
.global check_and_enable_a20
.global check_a20
.code32
check_and_enable_a20:
    call check_a20
    cmpl $1, %eax
    jne enable_a20_bios
    jmp a20_activated
check_a20:
    # Check if it is already enabled
    pushal
    movl $1, 0x112345
    movl $5, 0x012345
    movl 0x112345, %edi
    movl 0x012345, %esi
    cmpsl
    popal
    jne a20_activated
    movb $'1', %al
    call __spitredchar
    movl $0, %eax
    ret
.code16
enable_a20_bios:
    movb $'E', %al
    call __spitredchar
    movw    $0x2403, %ax
    int     $0x15
    jb      fast_a20
    cmpb    $0, %ah
    jnz     fast_a20

    movw    $0x2402, %ax
    int     $0x15
    jb      fast_a20
    cmpb    $0, %ah
    jnz     fast_a20

    cmpb    $1, %al
    jz      a20_activated

    movw    $0x2401, %ax
    int     $0x15
    jb      fast_a20
    cmpb    $0, %ah
    jnz     fast_a20
.code32
fast_a20:
    inb $0x92, %al
    testb $2, %al
    jnz after_fast_a20
    orb $2, %al
    andb $0xFE, %al
    outb %al, $0x92
after_fast_a20:
    call check_a20
    cmpl $1, %eax
    jne a20_inactive
# The definition of spaghetti code. TODO: reorganize.
a20_activated:
    movb $'2', %al
    call __spitredchar
    movl $1, %eax
    ret
a20_inactive:
    movb $'3', %al
    call __spitredchar
    movl $0, %eax
    ret
