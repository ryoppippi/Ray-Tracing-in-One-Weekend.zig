const std = @import("std");
const _main = @import("main.zig");

const Config = _main.Config;

var gpa: @TypeOf(std.heap.GeneralPurposeAllocator(.{}){}) = undefined;
var arena: std.heap.ArenaAllocator = undefined;
var allocator: std.mem.Allocator = undefined;
var array: [][]u32 = undefined;

export fn getArrayPointer() [*]u32 {
    return @ptrCast([*]u32, @alignCast(4, array));
}

export fn init() void {
    gpa = std.heap.GeneralPurposeAllocator(.{}){};
    arena = std.heap.ArenaAllocator.init(gpa.allocator());
    allocator = arena.allocator();
}

export fn deinit() void {
    arena.deinit();
}

export fn main() void {
    const config = Config{
        .aspect_ratio = 3.0 / 2.0,
        .image_width = 30,
        .samples_per_pixel = 20,
    };

    array = _main.mainRender(config, false, allocator) catch unreachable;
}
