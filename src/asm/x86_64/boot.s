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
.global pdt
.global pdpt
.global pml4
.extern start64
.extern check_and_enable_a20
.extern activate_long_mode
.extern enable_compatibility_paging
.extern __spitredchar
.extern __spitgreenchar
.section .text
.code32
start:
    # Set up the stack
    movl stack_top, %esp
    # enable A20
    call check_and_enable_a20
    call a20_ok
    # Activate long compatibility mode
    call activate_long_mode
    call enable_compatibility_paging
    call long_compatibility_mode_ok
    lgdt (__aftergdtloc)
    call lgdt_appears_ok
longjumpto64:
    ljmpl $__offsetforgdtcode, $start64
    hlt

a20_ok:
    movb $'A', %al
    call __spitgreenchar
    movb $'2', %al
    call __spitgreenchar
    movb $'0', %al
    call __spitgreenchar
    movb $' ', %al
    call __spitgreenchar
    ret

long_compatibility_mode_ok:
    movb $'L', %al
    call __spitgreenchar
    movb $'M', %al
    call __spitgreenchar
    movb $'C', %al
    call __spitgreenchar
    movb $' ', %al
    call __spitgreenchar
    ret

lgdt_appears_ok:
    movb $'G', %al
    call __spitgreenchar
    movb $'D', %al
    call __spitgreenchar
    movb $'T', %al
    call __spitgreenchar
    movb $' ', %al
    call __spitgreenchar
    ret

.section .bss
.balign 4096
pml4:
    .skip 4096
pdpt:
    .skip 4096
pdt:
    .skip 4096
stack_bottom:
    # Revise the stack size.
    .skip 1024
stack_top:

.section .rodata
gdt64:
    .quad 0
.set __offsetforgdtcode, 1f - gdt64
1:
    .quad (1<<43) | (1<<44) | (1<<47) | (1<<53)
__aftergdtloc:
    .word __aftergdtloc - gdt64 - 1
    .quad gdt64
