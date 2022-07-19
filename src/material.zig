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

const f3 = rtw.f3;

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,
    Dielectric: Dielectric,

    pub fn lambertian(albedo: Vec3) Material {
        return Material{ .Lambertian = Lambertian{ .albedo = albedo } };
    }

    pub fn metal(albedo: Vec3, fuzz: SType) Material {
        return Material{ .Metal = Metal{ .albedo = albedo, .fuzz = fuzz } };
    }

    pub fn dielectric(ir: SType) Material {
        return Material{ .Dielectric = Dielectric{ .ir = ir } };
    }
};

const Lambertian = struct {
    albedo: Color,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray, rnd: *RandGen) bool {
        _ = r_in;
        var scatter_direction = rec.normal + vec.randomUnitVector(rnd, Color);

        if (vec.nearZero(scatter_direction)) {
            scatter_direction = rec.normal;
        }

        scattered.* = Ray{ .origin = rec.p, .direction = scatter_direction };
        attenuation.* = self.albedo;
        return true;
    }
};

const Metal = struct {
    albedo: Color,
    fuzz: SType,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray, rnd: *RandGen) bool {
        const reflected = vec.reflect(vec.unit(r_in.direction), rec.normal);
        scattered.* = Ray{ .origin = rec.p, .direction = reflected + f3(self.fuzz) * vec.randomInUnitSphere(rnd, Vec3) };
        attenuation.* = self.albedo;
        return vec.dot(scattered.direction, rec.normal) > 0.0;
    }
};

const Dielectric = struct {
    ir: SType,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        attenuation.* = Color{ 1.0, 1.0, 1.0 };
        const refraction_ratio = if (rec.front_face) (1.0 / self.ir) else self.ir;

        const unit_direction = vec.unit(r_in.direction);
        const cos_theta = math.min(vec.dot(-unit_direction, rec.normal), 1.0);
        const sin_theta = math.sqrt(1.0 - cos_theta * cos_theta);
        const cannot_refract = refraction_ratio * sin_theta > 1.0;

        const direction = switch (cannot_refract) {
            true => vec.reflect(unit_direction, rec.normal),
            false => vec.refract(unit_direction, rec.normal, refraction_ratio),
        };

        scattered.* = Ray{ .origin = rec.p, .direction = direction };

        return true;
    }
};
