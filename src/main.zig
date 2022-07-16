const std = @import("std");

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    const image_width: u16 = 256;
    const image_height: u16 = 256;

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    var j: i16 = image_height - 1;
    while (0 <= j) : (j -= 1) {
        var i: i16 = 0;
        while (i < image_width) : (i += 1) {
            const r = @intToFloat(f64, i) / @intToFloat(f64, image_width - 1);
            const g = @intToFloat(f64, j) / @intToFloat(f64, image_height - 1);
            const b = 0.25;
            const ir = @floatToInt(u16, 255.999 * r);
            const ig = @floatToInt(u16, 255.999 * g);
            const ib = @floatToInt(u16, 255.999 * b);

            try stdout.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }
    }
}
