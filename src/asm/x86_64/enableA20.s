.section .text
.extern asmdie
enable_a20:
    movw    $0x2403,%ax
    int     $0x15
    jb      a20die
    cmpb    $0,%ah
    jnz     a20die

    movw    $0x2402,%ax
    int     $0x15
    jb      a20die
    cmpb    $0,%ah
    jnz     a20die

    cmpb    $1,%al
    jz      a20_activated

    movw    $0x2401,%ax
    int     $0x15
    jb      a20die
    cmpb    $0,%ah
    jnz     a20die
a20_activated:
    ret
a20die:
    call asmdie
