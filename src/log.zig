const std = @import("std");

const LOG_INIT: *volatile u16 = @ptrFromInt(0x04FFF780);
const LOG_BUFFER: *volatile [0x100]u8 = @ptrFromInt(0x04FFF600);
const LOG_SEND: *volatile Level = @ptrFromInt(0x04FFF700);

const Level = enum(u16) {
    fatal = 0x100,
    err = 0x101,
    warn = 0x102,
    info = 0x103,
    debug = 0x104,
};

pos: usize = 0,
is_running_in_mgba: bool,

const Self = @This();

const Writer = std.io.Writer(*Self, error{EndOfBuffer}, write);

pub fn init() Self {
    LOG_INIT.* = 0xC0DE;
    const is_init = LOG_INIT.*;
    return Self{ .is_running_in_mgba = is_init == 0x1DEA };
}

fn write(self: *Self, data: []const u8) error{EndOfBuffer}!usize {
    if (!self.is_running_in_mgba) { // ignore when running outside of mGBA
        return data.len;
    }
    if (self.pos + data.len + 1 > LOG_BUFFER.len) { // +1 because we need to insert \x00 at the end.
        return error.EndOfBuffer;
    }
    for (0..data.len) |i| {
        LOG_BUFFER[self.pos + i] = data[i];
    }
    self.pos += data.len;

    return data.len;
}

fn writer(self: *Self) Writer {
    return .{ .context = self };
}

pub fn print(self: *Self, comptime level: Level, comptime format: []const u8, args: anytype) error{EndOfBuffer}!void {
    var w = self.writer();
    self.pos = 0;

    try w.print(format, args);

    LOG_BUFFER[self.pos] = '\x00';
    LOG_SEND.* = level;
}
