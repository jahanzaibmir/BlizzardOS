/* kernel/arch/x86/linker.ld
 * places the kernel at 1 MiB physical — standard for multiboot
 * anything below 1 MiB is BIOS/real-mode territory, we stay out of it
 */

ENTRY(_start)

SECTIONS {
    . = 0x00100000;     /* load address: 1 MiB */

    /* multiboot header has to be within the first 8 KiB of the binary */
    .multiboot ALIGN(4) : {
        *(.multiboot)
    }

    /* executable code */
    .text ALIGN(4096) : {
        *(.text)
        *(.text.*)
    }

    /* read-only data — string literals, const globals */
    .rodata ALIGN(4096) : {
        *(.rodata)
        *(.rodata.*)
    }

    /* initialised read-write data */
    .data ALIGN(4096) : {
        *(.data)
        *(.data.*)
    }

    /* zero-initialised data — exists in memory but not in the ELF file */
    .bss ALIGN(4096) : {
        *(COMMON)
        *(.bss)
        *(.bss.*)
    }

    /* kernel_end marks where the image stops — pmm uses this to know
     * where free memory begins */
    . = ALIGN(4096);
    PROVIDE(kernel_end = .);
}
