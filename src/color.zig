const std = @import("std");
const rtw = @import("rtweekend.zig");

pub fn writeColor(writer: anytype, pixelColor: rtw.Color) !void {
    const ir = @floatToInt(u16, 255.999 * pixelColor[0]);
    const ig = @floatToInt(u16, 255.999 * pixelColor[1]);
    const ib = @floatToInt(u16, 255.999 * pixelColor[2]);

    try writer.print("{d} {d} {d}\n", .{ ir, ig, ib });
}
