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
.section .text
.extern __spitredchar
.extern asmdie
.global check_and_enable_a20
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
    movl $0, %eax
    ret
.code16
enable_a20_bios:
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
    call check_a20
    cmpl $1, %eax
    je a20_activated
    # More complex enable process.
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
    movl $1, %eax
    ret
a20_inactive:
    pushl $'A'
    call asmdie
    popl %eax
    movl $0, %eax
    ret
