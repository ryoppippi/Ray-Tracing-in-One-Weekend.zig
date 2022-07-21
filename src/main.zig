const std = @import("std");
const math = std.math;
const debug = std.debug;
const vec = @import("vec.zig");
const rtw = @import("rtweekend.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const hittableList = @import("hittableList.zig");
const sphere = @import("sphere.zig");
const camera = @import("camera.zig");
const material = @import("material.zig");
const randomScene = @import("randomScene.zig");

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
const Scatter = material.Scatter;

const dot = vec.dot;
const f3 = rtw.f3;
const test_allocator = std.testing.allocator;

const infinity = rtw.getInfinity(SType);

fn rayColor(r: Ray, world: HittableList, rnd: *RandGen, comptime depth: comptime_int) Color {
    const black: Color = Color{ 0.0, 0.0, 0.0 };

    {
        var return_color = Color{ 1.0, 1.0, 1.0 };
        var scattered: Ray = r;
        var rec: HitRecord = undefined;

        var i: isize = 0;
        while (i < depth) : (i += 1) {
            const world_hit = world.hit(scattered, 0.001, infinity);
            rec = world_hit.rec;
            if (world_hit.is_hit) {
                const s: Scatter = switch (rec.mat) {
                    .Lambertian => |l| l.scatter(scattered, rec, rnd),
                    .Metal => |m| m.scatter(scattered, rec, rnd),
                    .Dielectric => |d| d.scatter(scattered, rec, rnd),
                };
                const is_scattered = s.is_scattered;
                scattered = s.scattered;
                const attenuation = s.attenuation;
                if (is_scattered) {
                    return_color *= attenuation;
                    continue;
                }
                return black;
            }
            const unit_direction = vec.unit(scattered.direction);
            const t = 0.5 * (unit_direction[1] + 1.0);
            return_color *= (f3(1.0 - t) * Color{ 1.0, 1.0, 1.0 } + f3(t) * Color{ 0.5, 0.7, 1.0 });
            return return_color;
        }
    }
    return black;

    // if (depth <= 0) {
    //     return Color{ 0.0, 0.0, 0.0 };
    // }
    //
    // if (world.*.hit(r, 0.001, infinity, &rec)) {
    //     var scattered: Ray = undefined;
    //     var attenuation: Color = undefined;
    //     const is_scattered: bool = switch (rec.mat) {
    //         .Lambertian => |l| l.scatter(r, rec, &attenuation, &scattered, rnd),
    //         .Metal => |m| m.scatter(r, rec, &attenuation, &scattered, rnd),
    //         .Dielectric => |d| d.scatter(r, rec, &attenuation, &scattered, rnd),
    //     };
    //     if (is_scattered) {
    //         return attenuation * rayColor(scattered, world, rnd, depth - 1);
    //     }
    //     return Color{ 0.0, 0.0, 0.0 };
    // }
    // const unit_direction = vec.unit(r.direction);
    // const t = 0.5 * (unit_direction[1] + 1.0);
    // return f3(1.0 - t) * Color{ 1.0, 1.0, 1.0 } + f3(t) * Color{ 0.5, 0.7, 1.0 };
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();
    var rnd = RandGen.init(0);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // image
    const aspect_ratio = 3.0 / 2.0;
    const image_width: isize = 1200;
    comptime var image_height: isize = @intToFloat(@TypeOf(aspect_ratio), image_width) / aspect_ratio;
    const samples_per_pixel: isize = 500;
    const max_depth: isize = 50;

    // world
    var world = HittableList.init(arena.allocator());
    defer world.deinit();
    try randomScene.genWorld(&rnd, &world);

    // camera
    const lookfrom = Point3{ 13, 2, 3 };
    const lookat = Point3{ 0, 0, 0 };
    const vup = Vec3{ 0, 1, 0 };
    const vfov = 20;
    const dist_to_focus = 10.0;
    const apature = 0.1;
    const cam = Camera.init(
        lookfrom,
        lookat,
        vup,
        vfov,
        aspect_ratio,
        apature,
        dist_to_focus,
    );

    // Render
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    {
        var j: isize = image_height - 1;
        while (0 <= j) : (j -= 1) {
            debug.print("{d}%\n", .{@round(@intToFloat(f16, image_height - j) / @intToFloat(f16, image_height - 1) * 100)});
            {
                var i: isize = 0;
                while (i < image_width) : (i += 1) {
                    var pixel_color = Color{ 0, 0, 0 };
                    {
                        var s: isize = 0;
                        while (s < samples_per_pixel) : (s += 1) {
                            const u: SType = (@intToFloat(SType, i) + rtw.getRandom(&rnd, SType)) / @intToFloat(SType, image_width - 1);
                            const v: SType = (@intToFloat(SType, j) + rtw.getRandom(&rnd, SType)) / @intToFloat(SType, image_height - 1);
                            const r = cam.getRay(u, v, &rnd);
                            pixel_color += rayColor(r, world, &rnd, max_depth);
                        }
                    }
                    try color.writeColor(stdout, pixel_color, samples_per_pixel);
                }
            }
        }
    }
    debug.print("done", .{});
}
