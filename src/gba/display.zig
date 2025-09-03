const logger = @import("log.zig");

const IO_DISPLAY_CONTROL: *volatile DisplayControl = @ptrFromInt(0x04000000);
const VRAM: [*]volatile u16 = @ptrFromInt(0x06000000);
const VRAM_OBJ_TILE: *volatile [512]u32 = @ptrFromInt(0x06010000);
const BG_PALETTE: *volatile [16]u32 = @ptrFromInt(0x05000000);
const SPR_PALETTE: *volatile [16]u32 = @ptrFromInt(0x05000200);
const VCOUNT: *volatile u8 = @ptrFromInt(0x04000006);

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

pub fn load_palette(palette: [16]u32) void {
    for (0..palette.len) |i| {
        SPR_PALETTE[i] = palette[i];
    }
}

pub fn load_tiles(tiles: [512]u32) void {
    for (0..tiles.len) |i| {
        VRAM_OBJ_TILE[i] = tiles[i];
    }
}

pub fn set_display_ctrl(ctrl: DisplayControl) void {
    IO_DISPLAY_CONTROL.* = ctrl;
}

pub fn wait_for_vblank() void {
    while (VCOUNT.* >= 160) {}
    while (VCOUNT.* < 160) {}
    logger.print(.warn, "vcount={d}", .{VCOUNT.*}) catch {};
}
