const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Ray = ray.Ray;
const SType = rtw.SType;
const HitRecord = hittable.HitRecord;
const RandGen = rtw.RandGen;

pub const Scatter = struct {
    attenuation: Vec3,
    ray: Ray,
    is_scattered: bool,
};

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,

    pub fn lambertian(albedo: Vec3) Material {
        return Material{ .Lambertian = Lambertian{ .albedo = albedo } };
    }

    pub fn metal(albedo: Vec3) Material {
        return Material{ .Metal = Metal{ .albedo = albedo } };
    }
};

const Lambertian = struct {
    albedo: Color,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, rnd: *RandGen) Scatter {
        _ = r_in;
        var scatter_direction = rec.normal + vec.randomUnitVector(rnd, Color);

        if (vec.nearZero(scatter_direction)) {
            scatter_direction = rec.normal;
        }

        const scattered = Ray{ .origin = rec.p, .direction = scatter_direction };
        const attenuation = self.albedo;
        return Scatter{ .attenuation = attenuation, .ray = scattered, .is_scattered = true };
    }
};

const Metal = struct {
    albedo: Color,
    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord) Scatter {
        const reflected = vec.reflect(vec.unit(r_in.direction), rec.normal);
        const scattered = Ray{ .origin = rec.p, .direction = reflected };
        const attenuation = self.albedo;
        const is_scattered = vec.dot(scattered.direction, rec.normal) > 0.0;
        return Scatter{ .attenuation = attenuation, .ray = scattered, .is_scattered = is_scattered };
    }
};
