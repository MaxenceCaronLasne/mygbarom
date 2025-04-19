MEMORY {
  rom : ORIGIN = 0x08000000, LENGTH = 32M
  iwram : ORIGIN = 0x03000000, LENGTH = 32K
  ewram : ORIGIN = 0x02000000, LENGTH = 256K
}

ENTRY(_start)

OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
OUTPUT_ARCH(arm)

__text_start = ORIGIN(rom);
__text_end = ORIGIN(rom) + LENGTH(rom);

SECTIONS {
  . = __text_start;
  .text : {
    KEEP(*(.gbaheader))
    *(.text)
  } >rom = 0xff
}
