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

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const RandGen = rtw.RandGen;
const HittableList = hittableList.HittableList;
const Sphere = sphere.Sphere;
const Material = material.Material;

pub fn genWorld(rnd: *RandGen, world: *HittableList) anyerror!void {
    const ground_material = Material.lambertian(Color{ 0.5, 0.5, 0.5 });
    const ground_sphere = Sphere{ .center = Point3{ 0.0, -1000.0, 0.0 }, .radius = 1000.0, .mat = ground_material };
    _ = try world.add(ground_sphere);

    {
        var a: i32 = -11;
        while (a < 11) : (a += 1) {
            {
                var b: i32 = -11;
                while (b < 11) : (b += 1) {
                    {
                        var choose_mat = rtw.getRandom(rnd, SType);
                        const center = Point3{
                            @intToFloat(SType, a) + 0.9 * rtw.getRandom(rnd, SType),
                            0.2,
                            @intToFloat(SType, b) + 0.9 * rtw.getRandom(rnd, SType),
                        };
                        if (vec.len(center - Point3{ 4.0, 0.2, 0.0 }) > 0.9) {
                            // generate a random material
                            if (choose_mat < 0.8) {
                                // diffuse
                                const albedo = vec.randomVecInRange(rnd, Color, 0, 1) * vec.randomVecInRange(rnd, Color, 0, 1);
                                const diffuse_material = Material.lambertian(albedo);
                                const diffuse_sphere = Sphere{ .center = center, .radius = 0.2, .mat = diffuse_material };
                                _ = try world.add(diffuse_sphere);
                            } else if (choose_mat < 0.95) {
                                // metal
                                const albedo = vec.randomVecInRange(rnd, Color, 0.5, 1.0);
                                const fuzz = rtw.getRandomInRange(rnd, SType, 0.0, 0.5);
                                const metal_material = Material.metal(albedo, fuzz);
                                const metal_sphere = Sphere{ .center = center, .radius = 0.2, .mat = metal_material };
                                _ = try world.add(metal_sphere);
                            } else {
                                // glass
                                const ir = 1.5;
                                const glass_material = Material.dielectric(ir);
                                const glass_sphere = Sphere{ .center = center, .radius = 0.2, .mat = glass_material };
                                _ = try world.add(glass_sphere);
                            }
                        }
                    }
                }
            }
        }
    }

    const material1 = Material.dielectric(1.5);
    const sphere1 = Sphere{ .center = Point3{ 0.0, 1.0, 0.0 }, .radius = 1.0, .mat = material1 };
    _ = try world.add(sphere1);

    const material2 = Material.lambertian(Color{ 0.4, 0.2, 0.1 });
    const sphere2 = Sphere{ .center = Point3{ -4.0, 1.0, 0.0 }, .radius = 1.0, .mat = material2 };
    _ = try world.add(sphere2);

    const material3 = Material.metal(Color{ 0.7, 0.6, 0.5 }, 0.0);
    const sphere3 = Sphere{ .center = Point3{ 4.0, 1.0, 0.0 }, .radius = 1.0, .mat = material3 };
    _ = try world.add(sphere3);
}
