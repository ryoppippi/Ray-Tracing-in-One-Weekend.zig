const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");

const Vec3 = vec.Vec3;
const Color = vec.Color;
const Point3 = vec.Point3;
const Ray = ray.Ray;

const splat = vec.splat;

fn rayColor(r: Ray) Color {
    // const unit_direction = vec.unit(r.direction);  //TODO error: runtime value cannot be passed to comptime arg
    const unit_direction = r.direction / @splat(3, math.sqrt(@reduce(.Add, r.direction * r.direction)));
    const t = 0.5 * (unit_direction[1] + 1.0);
    return @splat(3, 1.0 - t) * Color{ 1.0, 1.0, 1.0 } + @splat(3, t) * Color{ 0.5, 0.7, 1.0 };
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    const aspect_ratio = 16.0 / 9.0;
    const image_width: u32 = 384;
    comptime var image_height: u32 = @intToFloat(@TypeOf(aspect_ratio), image_width) / aspect_ratio;

    const viewport_height = 2.0;
    const viweport_width = aspect_ratio * viewport_height;
    const focal_length = 1.0;

    const origin = Point3{ 0.0, 0.0, 0.0 };
    const horizontal = Vec3{ viweport_width, 0.0, 0.0 };
    const vertical = Vec3{ 0.0, viewport_height, 0.0 };
    const lower_left_corner = origin - horizontal / @splat(3, @as(f64, 2.0)) - vertical / @splat(3, @as(f64, 2.0)) - Vec3{ 0.0, 0.0, focal_length };

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (0 <= j) : (j -= 1) {
        var i: i32 = 0;
        while (i < image_width) : (i += 1) {
            const u = @as(f64, @intToFloat(f64, i) / @intToFloat(f64, image_width - 1));
            const v = @as(f64, @intToFloat(f64, j) / @intToFloat(f64, image_height - 1));
            const r: Ray = Ray{
                .origin = origin,
                .direction = lower_left_corner + @splat(3, u) * horizontal + @splat(3, v) * vertical - origin,
            };
            const pixelColor: Color = rayColor(r);
            try color.writeColor(stdout, pixelColor);
        }
    }
}
