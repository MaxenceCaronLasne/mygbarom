const tile_data = @import("metroid_sprite_data.zig");

const ObjMode = enum(u2) {
    normal,
    affine,
    disabled,
    double_affine,
};

const ObjGfx = enum(u2) {
    normal,
    alpha,
    window,
    _,
};

const ColorMode = enum(u1) {
    bpp4,
    bpp8,
};

const SpriteShape = enum(u2) {
    square,
    wide,
    tall,
    _,
};

const SpriteSize = enum(u2) {
    size_8,
    size_16,
    size_32,
    size_64,
};

const ObjAttr = packed struct(u48) {
    y: u8 = 0,
    object_mode: ObjMode = .normal,
    gfx: ObjGfx = .normal,
    is_mosaic_enabled: bool = false,
    color_mode: ColorMode = .bpp4,
    shape: SpriteShape = .square,
    x: u9 = 0,
    _: u3 = 0,
    is_hflip: bool = false,
    is_vflip: bool = false,
    size: SpriteSize = .size_8,
    tid: u10 = 0,
    priority: u2 = 0,
    palette_blank: u4 = 0,
};

const IO_DISPLAY_CONTROL: *volatile DisplayControl = @ptrFromInt(0x04000000);
const VRAM: [*]volatile u16 = @ptrFromInt(0x06000000);
const VRAM_OBJ_TILE: *volatile [512]u32 = @ptrFromInt(0x06010000);
const OAM: *volatile ObjAttr = @ptrFromInt(0x07000000);
const BG_PALETTE: *volatile [16]u32 = @ptrFromInt(0x05000000);
const SPR_PALETTE: *volatile [16]u32 = @ptrFromInt(0x05000200);
const LOG_INIT: *volatile u16 = @ptrFromInt(0x04FFF780);
const LOG_BUFFER: *volatile [128]u8 = @ptrFromInt(0x04FFF600);
const LOG_SEND: *volatile u16 = @ptrFromInt(0x04FFF700);

const BgMode = enum(u3) {
    mode0, // Tiled
    mode1, // Tiled
    mode2, // Tiled
    mode3, // Bitmap: 240x160; 16bpp; 1x 0x12C00; no page-flip
    mode4, // Bitmap: 240x160; 8bpp; 2x 0x9600; yes page-flip
    mode5, // Bitmap: 160x128; 16bpp; 2x 0xA000; yes page-flip
};

const ObjCharacterVramMapping = enum(u1) {
    two_dimensional,
    one_dimensional,
};

const DisplayControl = packed struct(u16) {
    bg_mode: BgMode = .mode0,
    cgb_mode_ro: bool = false, // read only
    display_frame_select: u1 = 0,
    is_hblank_interval_free: bool = false,
    obj_char_vram_mapping: ObjCharacterVramMapping = .two_dimensional,
    is_forced_blank: bool = false,
    is_bg0_displayed: bool = false,
    is_bg1_displayed: bool = false,
    is_bg2_displayed: bool = false,
    is_bg3_displayed: bool = false,
    is_obj_displayed: bool = false,
    is_window0_displayed: bool = false,
    is_window1_displayed: bool = false,
    is_obj_window_displayed: bool = false,
};

const Header = extern struct {
    entry_point: u32,
    nintendo_logo: [156]u8,
    game_name: [12]u8,
    game_code: [4]u8,
    maker_code: [2]u8,
    fixed_value: u8,
    unit_code: u8,
    device_type: u8,
    reserved1: [7]u8,
    software_version: u8,
    complement_check: u8,
    reserved2: [2]u8,
};

export var rom_header linksection(".gbaheader") = Header{
    // Fixed entry point instruction (branch to start + header size)
    .entry_point = 0xEA00002E,

    // Nintendo logo (compressed bitmap)
    .nintendo_logo = [_]u8{
        0x24, 0xFF, 0xAE, 0x51, 0x69, 0x9A, 0xA2, 0x21,
        0x3D, 0x84, 0x82, 0x0A, 0x84, 0xE4, 0x09, 0xAD,
        0x11, 0x24, 0x8B, 0x98, 0xC0, 0x81, 0x7F, 0x21,
        0xA3, 0x52, 0xBE, 0x19, 0x93, 0x09, 0xCE, 0x20,
        0x10, 0x46, 0x4A, 0x4A, 0xF8, 0x27, 0x31, 0xEC,
        0x58, 0xC7, 0xE8, 0x33, 0x82, 0xE3, 0xCE, 0xBF,
        0x85, 0xF4, 0xDF, 0x94, 0xCE, 0x4B, 0x09, 0xC1,
        0x94, 0x56, 0x8A, 0xC0, 0x13, 0x72, 0xA7, 0xFC,
        0x9F, 0x84, 0x4D, 0x73, 0xA3, 0xCA, 0x9A, 0x61,
        0x58, 0x97, 0xA3, 0x27, 0xFC, 0x03, 0x98, 0x76,
        0x23, 0x1D, 0xC7, 0x61, 0x03, 0x04, 0xAE, 0x56,
        0xBF, 0x38, 0x84, 0x00, 0x40, 0xA7, 0x0E, 0xFD,
        0xFF, 0x52, 0xFE, 0x03, 0x6F, 0x95, 0x30, 0xF1,
        0x97, 0xFB, 0xC0, 0x85, 0x60, 0xD6, 0x80, 0x25,
        0xA9, 0x63, 0xBE, 0x03, 0x01, 0x4E, 0x38, 0xE2,
        0xF9, 0xA2, 0x34, 0xFF, 0xBB, 0x3E, 0x03, 0x44,
        0x78, 0x00, 0x90, 0xCB, 0x88, 0x11, 0x3A, 0x94,
        0x65, 0xC0, 0x7C, 0x63, 0x87, 0xF0, 0x3C, 0xAF,
        0xD6, 0x25, 0xE4, 0x8B, 0x38, 0x0A, 0xAC, 0x72,
        0x21, 0xD4, 0xF8, 0x07,
    },

    // Game title (12 bytes, padded with zeroes)
    .game_name = [_]u8{ 'M', 'Y', 'G', 'B', 'A', 'R', 'O', 'M', 0, 0, 0, 0 },

    // Game code (4 bytes)
    .game_code = [_]u8{ 'M', 'G', 'R', 'M' },

    // Maker code (2 bytes)
    .maker_code = [_]u8{ '0', '0' },

    // Fixed value (must be 0x96)
    .fixed_value = 0x96,

    // Main unit code (0x00 for GBA)
    .unit_code = 0x00,

    // Device type (0x00)
    .device_type = 0x00,

    // Reserved (7 bytes of 0)
    .reserved1 = [_]u8{ 0, 0, 0, 0, 0, 0, 0 },

    // Software version (0)
    .software_version = 0x00,

    // Complement check (will be calculated at build time - placeholder)
    .complement_check = 0x00,

    // Reserved (2 bytes of 0)
    .reserved2 = [_]u8{ 0, 0 },
};

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

    LOG_INIT.* = 0xC0DE;
    const is_init = LOG_INIT.*;
    if (is_init != 0x1DEA) {
        @panic("aie");
    }

    LOG_BUFFER[0] = 'l';
    LOG_BUFFER[1] = 'o';
    LOG_BUFFER[2] = 'l';
    LOG_BUFFER[3] = '\x00';
    LOG_SEND.* = 0x102;

    // memcpy doesn't work properly, probably because volatile is not respected
    for (0..tile_data.pal.len) |i| {
        SPR_PALETTE[i] = tile_data.pal[i];
    }
    for (0..tile_data.tiles.len) |i| {
        VRAM_OBJ_TILE[i] = tile_data.tiles[i];
    }

    OAM.* = ObjAttr{
        .x = 0,
        .y = 0,
        .shape = .square,
        .size = .size_64,
    };

    IO_DISPLAY_CONTROL.* = DisplayControl{
        .bg_mode = .mode0,
        .obj_char_vram_mapping = .one_dimensional,
        .is_obj_displayed = true,
    };

    // VRAM[120 + 80 * 240] = 0x001F;
    // VRAM[136 + 80 * 240] = 0x03E0;
    // VRAM[120 + 96 * 240] = 0x7C00;

    while (true) {}
}
