const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");

const Color = rtw.Color;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const RandGen = rtw.RandGen;

// pub const material = struct {}

pub const Lambertian = struct {
    albedo: Color,
    const Self = This();

    pub fn init(albedo: Color) Self {
        return Self{ .albedo = albedo };
    }

    pub fn scatter(self: Self, r_in: Ray, rec: *HitRecord, color: Color, scattered: Ray, rnd: *RandGen) bool {
        const scatter_direction = rec.*.normal * vec.randomUnitVector(rnd, Color);
        const scattered = Ray{ .origin = rec.*.p, .direction = scatter_direction };
        attenuation = self.albedo;
        return true;
    }
};
