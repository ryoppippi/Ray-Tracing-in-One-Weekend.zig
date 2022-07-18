const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const hittableList = @import("hittableList.zig");
const sphere = @import("sphere.zig");
const rtw = @import("rtweekend.zig");

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const HittableList = hittableList.HittableList;
const Sphere = sphere.Sphere;

const dot = vec.dot;
const f3 = rtw.f3;

const infinity = rtw.infinity;

fn rayColor(r: Ray, world: *HittableList) Color {
    var rec: HitRecord = undefined;
    if (world.hit(r, 0, infinity, &rec)) {
        return f3(0.5) * (rec.normal + f3(1.0));
    }
    const unit_direction = vec.unit(r.direction);
    const t = 0.5 * (unit_direction[1] + 1.0);
    return f3(1.0 - t) * Color{ 1.0, 1.0, 1.0 } + f3(t) * Color{ 0.5, 0.7, 1.0 };
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    // image
    const aspect_ratio = 16.0 / 9.0;
    const image_width: u32 = 384;
    comptime var image_height: u32 = @intToFloat(@TypeOf(aspect_ratio), image_width) / aspect_ratio;

    // world
    var world = HittableList.init();
    defer world.deinit();
    _ = try world.add(Sphere{ .center = Point3{ 0, 0, -1 }, .radius = 0.5 });
    _ = try world.add(Sphere{ .center = Point3{ 0, -100.5, -1 }, .radius = 100 });

    // camera
    const viewport_height = 2.0;
    const viweport_width = aspect_ratio * viewport_height;
    const focal_length = 1.0;

    const origin = Point3{ 0.0, 0.0, 0.0 };
    const horizontal = Vec3{ viweport_width, 0.0, 0.0 };
    const vertical = Vec3{ 0.0, viewport_height, 0.0 };
    const lower_left_corner = origin - horizontal / f3(2) - vertical / f3(2) - Vec3{ 0.0, 0.0, focal_length };

    // Render
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (0 <= j) : (j -= 1) {
        var i: i32 = 0;
        while (i < image_width) : (i += 1) {
            const u = @as(SType, @intToFloat(SType, i) / @as(SType, image_width - 1));
            const v = @as(SType, @intToFloat(SType, j) / @as(SType, image_height - 1));
            const r: Ray = Ray{
                .origin = origin,
                .direction = lower_left_corner + f3(u) * horizontal + f3(v) * vertical,
            };
            const pixelColor: Color = rayColor(r, &world);
            try color.writeColor(stdout, pixelColor);
        }
    }
}
