const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");

const SType = rtw.SType;
const Color = rtw.Color;
const sqrt = math.sqrt;

pub fn writeColor(writer: anytype, pixel_color: Color, samples_per_pixel: anytype) !void {
    const T = ensureInt(@TypeOf(samples_per_pixel));
    const scale: SType = 1.0 / @intToFloat(SType, samples_per_pixel);
    const r: SType = sqrt(pixel_color[0] * scale);
    const g: SType = sqrt(pixel_color[1] * scale);
    const b: SType = sqrt(pixel_color[2] * scale);

    try writer.print("{d} {d} {d}\n", .{
        clp(r, T),
        clp(g, T),
        clp(b, T),
    });
}

inline fn clp(c: SType, comptime T: type) T {
    return @floatToInt(ensureInt(T), 256 * rtw.clamp(c, 0.0, 0.999));
}

inline fn ensureInt(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .ComptimeInt, .Int => T,
        else => @compileError("not implemented for " ++ @typeName(T)),
    };
}
