ENTRY(start)

SECTIONS {
    . = 1M;

    .boot BLOCK(4K) : ALIGN(4K)
    {
        *(.multiboot)
    }

    .text : ALIGN(4K)
    {
        *(.text)
    }

    .data : ALIGN(4K)
    {
        *(.data)
    }

    .rodata : ALIGN(4K)
    {
        *(.rodata)
    }
}
