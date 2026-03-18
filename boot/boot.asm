; boot/boot.asm
; multiboot 1 header — tells GRUB how to load us
;
; flags meaning:
;   bit 0 - align modules to page boundaries
;   bit 1 - give us a memory map
;   bit 2 - we want framebuffer info (address etc in mb_info)
;
; bit 16 (aout kludge) is intentionally NOT set
; since we arre an ELF binary, GRUB just reads the ELF headers

MULTIBOOT_MAGIC    equ 0x1BADB002
MULTIBOOT_FLAGS    equ 0x00000007
MULTIBOOT_CHECKSUM equ -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

section .multiboot
align 4
    dd MULTIBOOT_MAGIC
    dd MULTIBOOT_FLAGS
    dd MULTIBOOT_CHECKSUM

    ; video mode fields — only matter because bit 2 is set
    ; no aout fields needed since bit 16 is clear
    dd 0        ; header_addr   (ignored, we're ELF)
    dd 0        ; load_addr     (ignored, we're ELF)
    dd 0        ; load_end_addr (ignored, we're ELF)
    dd 0        ; bss_end_addr  (ignored, we're ELF)
    dd 0        ; entry_addr    (ignored, we're ELF)
    dd 0        ; mode_type: 0 = linear graphics, 1 = EGA text
    dd 1024     ; width
    dd 768      ; height
    dd 32       ; depth (bits per pixel)

section .bss
align 16
stack_bottom:
    resb 16384  ; 16kb stack
stack_top:

section .text
global _start
extern kernel_main

_start:
    mov  esp, stack_top

    push ebx        ; multiboot info pointer
    push eax        ; multiboot magic number

    ; clear flags register before jumping into C
    push 0
    popf

    call kernel_main

    ; if kernel_main ever returns, just hang
.hang:
    cli
    hlt
    jmp .hang

section .note.GNU-stack noalloc noexec nowrite progbits
