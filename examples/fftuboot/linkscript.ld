OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_Reset)

MEMORY
{
    /*ROM (rx) : ORIGIN = 0xC2000040, LENGTH = 1M*/
    /*ROM (rx) : ORIGIN = 0x2FFE0000, LENGTH = 128K*/
    /*RAM (rwx): ORIGIN = 0xC0200000, LENGTH = 1M*/
    RAM (rwx): ORIGIN = 0x2FFC0000, LENGTH = 256K
	SRAM1 (rwx) : ORIGIN = 0x10000000, LENGTH = 128K
	SRAM2 (rwx) : ORIGIN = 0x10020000, LENGTH = 128K
	SRAM3 (rwx) : ORIGIN = 0x10040000, LENGTH = 64K
	SRAM4 (rwx) : ORIGIN = 0x10050000, LENGTH = 64K
}


SECTIONS
{
    .text : {
        *(.vector_table)
        *(.text)
        *(.text*)
        . = ALIGN(8);
     } > RAM

	/* .rodata sections (constants, strings, etc.) */
	.rodata :
	{
		. = ALIGN(8);
		*(.rodata)         
		*(.rodata*) 
		. = ALIGN(8);
	} > SRAM1

    _text_end = .;

    .data : AT(_text_end)
    {
        . = ALIGN(8);
        _data_start = .;
        *(.data)
        *(.data*)
        . = ALIGN(8);
        _data_end = .;
    } > SRAM1

    .bss : {
        _bss_start = .;
        *(.bss)
        *(.bss*)   /* required for some malloc calls */
		*(COMMON)  /* required for libc, such as __lock___atexit_recursive_mutex */
        . = ALIGN(8);
        _bss_end = .;
    } > SRAM1

	end = . ;

	.ARM.attributes 0 : { *(.ARM.attributes) }
}
