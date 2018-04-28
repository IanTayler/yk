.section .data
    charpos: .int 0

.section .text
.global asmdie
asmdie:
    hlt

.code32
.global __spitredchar
__spitredchar:
    pushal
    movl $0xb8000, %edx
    movl charpos, %ecx
    addl %ecx, %edx
    movb $0x4f, 1(%edx)
    movb %al, 0(%edx)
    addl $2, charpos
    popal
    ret
