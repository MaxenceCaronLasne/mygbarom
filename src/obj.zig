pub const OAM: *volatile Attribute = @ptrFromInt(0x07000000);
var SHADOW: Attribute = Attribute{};

const Mode = enum(u2) {
    normal,
    affine,
    disabled,
    double_affine,
};

const Gfx = enum(u2) {
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

pub const Attribute = packed struct(u48) {
    y: u8 = 0,
    object_mode: Mode = .normal,
    gfx: Gfx = .normal,
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

pub fn set(attribute: Attribute) void {
    SHADOW = attribute;
}
pub fn get() *Attribute {
    return &SHADOW;
}

pub fn commit() void {
    OAM.* = SHADOW;
}
