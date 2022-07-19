const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");
const rtw = @import("rtweekend.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const hittableList = @import("hittableList.zig");
const sphere = @import("sphere.zig");
const camera = @import("camera.zig");
const material = @import("material.zig");

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const RandGen = rtw.RandGen;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const HittableList = hittableList.HittableList;
const Sphere = sphere.Sphere;
const Camera = camera.Camera;
const Material = material.Material;

const dot = vec.dot;
const f3 = rtw.f3;

const infinity = rtw.getInfinity(SType);

fn rayColor(r: Ray, world: *HittableList, rnd: *RandGen, comptime depth: comptime_int) Color {
    var rec: HitRecord = undefined;

    if (depth <= 0) {
        return Color{ 0.0, 0.0, 0.0 };
    }

    if (world.*.hit(r, 0.001, infinity, &rec)) {
        var scattered: Ray = undefined;
        var attenuation: Color = undefined;
        const is_scattered: bool = switch (rec.mat.*) {
            .Lambertian => |l| l.scatter(r, rec, &attenuation, &scattered, rnd),
            .Metal => |m| m.scatter(r, rec, &attenuation, &scattered, rnd),
            .Dielectric => |d| d.scatter(r, rec, &attenuation, &scattered, rnd),
        };
        if (is_scattered) {
            return attenuation * rayColor(scattered, world, rnd, depth - 1);
        }
        return Color{ 0.0, 0.0, 0.0 };
    }
    const unit_direction = vec.unit(r.direction);
    const t = 0.5 * (unit_direction[1] + 1.0);
    return f3(1.0 - t) * Color{ 1.0, 1.0, 1.0 } + f3(t) * Color{ 0.5, 0.7, 1.0 };
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();
    var rnd = RandGen.init(0);

    // image
    const aspect_ratio = 16.0 / 9.0;
    const image_width: u32 = 400;
    comptime var image_height: u32 = @intToFloat(@TypeOf(aspect_ratio), image_width) / aspect_ratio;
    const samples_per_pixel: u32 = 100;
    const max_depth: u32 = 50;

    // world
    const R = math.cos(math.pi / 4.0);
    var world = HittableList.init();
    defer world.deinit();

    const material_left = Material.lambertian(Color{ 0.0, 0.0, 1.0 });
    const material_right = Material.lambertian(Color{ 1.0, 0.0, 0.0 });

    _ = try world.add(Sphere{ .center = Point3{ -R, 0, -1 }, .radius = R, .mat = &material_left });
    _ = try world.add(Sphere{ .center = Point3{ R, 0, -1 }, .radius = R, .mat = &material_right });

    // camera
    const cam = Camera.init(90.0, aspect_ratio);

    // Render
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    {
        var j: i32 = image_height - 1;
        while (0 <= j) : (j -= 1) {
            {
                var i: i32 = 0;
                while (i < image_width) : (i += 1) {
                    var pixel_color = Color{ 0, 0, 0 };
                    var s: i32 = 0;
                    while (s < samples_per_pixel) : (s += 1) {
                        const u: SType = (@intToFloat(SType, i) + rtw.getRandom(&rnd, SType)) / @intToFloat(SType, image_width - 1);
                        const v: SType = (@intToFloat(SType, j) + rtw.getRandom(&rnd, SType)) / @intToFloat(SType, image_height - 1);
                        const r = cam.getRay(u, v);
                        pixel_color += rayColor(r, &world, &rnd, max_depth);
                    }
                    try color.writeColor(stdout, pixel_color, samples_per_pixel);
                }
            }
        }
    }
}
