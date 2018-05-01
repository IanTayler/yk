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
.extern asmdie
.extern pml4
.extern pdpt
.extern pdt
.extern pt
.global activate_long_mode
.global enable_compatibility_paging
.code32
activate_long_mode:
check_cpuid:
    pushfl
    popl %eax
    movl %eax, %ecx
    xorl $1 << 21, %eax
    pushl %eax
    popfl
    pushfl
    popl %eax
    pushl %ecx
    popfl
    cmp %eax, %ecx
    pushl $'0'
    je asmdie
    popl %eax
    movl $0x80000000, %eax
    cpuid
    cmpl $0x80000001, %eax
    pushl $'1'
    jb asmdie
    popl %eax
check_long_mode:
    movl $0x80000001, %eax
    cpuid
    testl $1 << 29, %edx
    pushl $'2'
    jz asmdie
    popl %eax
    # Code continues running.
set_identity_long_paging:
    movl $pdpt, %eax
    orl $0b11, %eax
    movl %eax, pml4
    movl $pdt, %eax
    orl $0b11, %eax
    movl %eax, pdpt
    # Counter used with loop
    movl $0, %ecx
set_pdt_loop:
    movl $0x200000, %eax
    mull %ecx
    orl $0b10000011, %eax
    movl $pdt, %ebx
    leal (%ebx,%ecx,8), %ebx
    movl %eax, 0(%ebx)

    incl %ecx
    cmpl $512, %ecx
    jne set_pdt_loop
    ret
enable_compatibility_paging:
    # Copy pml4 to cr3.
    movl pml4, %eax
    movl %eax, %cr3
    # CR4 has a few important flags.
    # We will set the Physical Address Extension
    movl %cr4, %eax
    orl $1 << 5, %eax
    movl %eax, %cr4
    # Set long mode in EFER MSR
    movl $0xc0000080, %ecx
    rdmsr
    orl $1 << 8, %eax
    wrmsr
    # CR0 also has a buch of flags.
    # We will enable the use of pages.
    movl %cr0, %eax
    orl $1 << 31, %eax
    movl %eax, %cr0
    # TODO: breaking HERE!!
    ret
