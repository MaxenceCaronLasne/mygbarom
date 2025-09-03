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

pub fn init() void {
    LOG_INIT.* = 0xC0DE;
}

pub fn print(comptime level: Level, comptime format: []const u8, args: anytype) error{NoSpaceLeft}!void {
    var buffer: [256]u8 = undefined;
    const formatted = std.fmt.bufPrint(&buffer, format, args) catch |err| switch (err) {
        error.NoSpaceLeft => return error.NoSpaceLeft,
    };

    for (0..formatted.len) |i| {
        LOG_BUFFER[i] = formatted[i];
    }
    LOG_BUFFER[formatted.len] = '\x00';
    LOG_SEND.* = level;
}
