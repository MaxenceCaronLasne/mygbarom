const std = @import("std");
const IWRAM: *volatile [0x2000]u8 = @ptrFromInt(0x03000000);
const EWRAM: *volatile [0x20000]u8 = @ptrFromInt(0x02000000);

var iwram_fba: std.heap.FixedBufferAllocator = undefined;
var iwram_initialized: bool = false;

pub fn iwram_allocator() std.mem.Allocator {
    if (!iwram_initialized) {
        iwram_fba = std.heap.FixedBufferAllocator.init(@volatileCast(IWRAM));
        iwram_initialized = true;
    }
    return iwram_fba.allocator();
}
