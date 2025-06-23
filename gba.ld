MEMORY {
  rom (rx) : ORIGIN = 0x08000000, LENGTH = 32M
  iwram (rw) : ORIGIN = 0x03000000, LENGTH = 32K
  ewram (rw): ORIGIN = 0x02000000, LENGTH = 256K
}

ENTRY(_start)

OUTPUT_FORMAT("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
OUTPUT_ARCH(arm)

__text_start = ORIGIN(rom);
__text_end = ORIGIN(rom) + LENGTH(rom);
__iwram_start = ORIGIN(iwram);
__iwram_end = ORIGIN(iwram) + LENGTH(iwram);
__sp_svc = __iwram_end - 0x20;
__sp_irq = __sp_svc - 0x40;
__sp_usr = __sp_irq - 0xA0;

/*
__sp_svc = 0x03007FE0;
__sp_irq = 0x03007FA0;
__sp_usr = 0x03007F00;
*/

SECTIONS {
  . = __text_start;
  .text : {
    KEEP(*(.gbaheader)) /* KEEP to keep the section even if no symbol is referenced */
    *(.text)
  } >rom = 0xff
}
