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

.section .text
start:
    hlt
