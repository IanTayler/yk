/*
yk - yet another kernel for unix-like systems.
Copyright (C) 2018 Ian G. Tayler <ian.g.tayler@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this program.  If not, see
<http://www.gnu.org/licenses/>.
*/
.section .data
    charpos: .int 0

.section .text
.global asmdie
.code32
asmdie:
    movb $'E', %al
    call __spitredchar
    movb $'R', %al
    call __spitredchar
    movb $'R', %al
    call __spitredchar
    popl %eax
    call __spitredchar
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
.global __spitgreenchar
__spitgreenchar:
    pushal
    movl $0xb8000, %edx
    movl charpos, %ecx
    addl %ecx, %edx
    movb $0x2f, 1(%edx)
    movb %al, 0(%edx)
    addl $2, charpos
    popal
    ret
