const tile_data = @import("metroid_sprite_data.zig");

const logger = @import("gba/log.zig");
const obj = @import("gba/obj.zig");
const display = @import("gba/display.zig");
const header = @import("gba/header.zig");
const mem = @import("gba/mem.zig");
const ecs = @import("ecs");

export var rom_header linksection(".gbaheader") = header.init("MYGBAROM0000", "MGRM", "MC");

pub fn main() anyerror!void {
    logger.init();

    _ = ecs.Registry.init(mem.iwram_allocator());

    // memcpy doesn't work properly, probably because volatile is not respected
    display.load_palette(tile_data.pal);
    display.load_tiles(tile_data.tiles);

    display.set_display_ctrl(.{
        .bg_mode = .mode0,
        .obj_char_vram_mapping = .one_dimensional,
        .is_obj_displayed = true,
    });

    var x: u9 = 100;
    var y: u8 = 50;

    while (true) {
        try logger.print(.debug, "loop", .{});

        const attr = obj.Attribute{
            .x = x,
            .y = y,
            .shape = .square,
            .size = .size_64,
        };

        x += 1;
        y += 1;

        display.wait_for_vblank();
        obj.OAM.* = attr;
    }
}
