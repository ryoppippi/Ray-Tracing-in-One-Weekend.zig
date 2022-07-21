const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");

const SType = rtw.SType;
const Color = rtw.Color;
const sqrt = math.sqrt;

pub fn writeColor(pixel_color: Color, samples_per_pixel: anytype) [3]isize {
    _ = ensureInt(@TypeOf(samples_per_pixel));
    const scale: SType = 1.0 / @intToFloat(SType, samples_per_pixel);
    const r: SType = sqrt(pixel_color[0] * scale);
    const g: SType = sqrt(pixel_color[1] * scale);
    const b: SType = sqrt(pixel_color[2] * scale);

    return [3]isize{
        clp(r, isize),
        clp(g, isize),
        clp(b, isize),
    };
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
