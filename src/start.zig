const main = @import("main.zig").main;

export fn _start() noreturn {
    asm volatile (
        \\.arm
        \\.cpu arm7tdmi
        // Stop interrupts (0x4000000 + 0x208 = master interrupt enable register)
        \\mov r0, #0x4000000
        \\str r0, [r0, #0x208]
        // Set mode to IRQ (0b10010) and set mode stack pointer
        \\mov r0, #0x12
        \\msr cpsr, r0
        \\ldr sp, =__sp_irq
        // Set mode to privileged user (0b11111) and set mode stack pointer
        \\mov r0, #0x1f
        \\msr cpsr, r0
        \\ldr sp, =__sp_usr
        // Jump to next instruction in thumb mode
        \\add r0, pc, #1
        \\bx r0
    );

    main() catch @panic("main exited with error");

    while (true) {}
}
