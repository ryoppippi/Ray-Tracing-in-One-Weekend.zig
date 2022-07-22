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

pub const Scatter = struct {
    attenuation: Color,
    scattered: Ray,
    is_scattered: bool,
};

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,
    Dielectric: Dielectric,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, rnd: *RandGen) Scatter {
        return switch (self) {
            .Lambertian => |l| l.scatter(r_in, rec, rnd),
            .Metal => |m| m.scatter(r_in, rec, rnd),
            .Dielectric => |d| d.scatter(r_in, rec, rnd),
        };
    }

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

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, rnd: *RandGen) Scatter {
        _ = r_in;
        var scatter_direction = rec.normal + vec.randomUnitVector(rnd, Color);

        if (vec.nearZero(scatter_direction)) {
            scatter_direction = rec.normal;
        }

        const scattered = Ray{ .origin = rec.p, .direction = scatter_direction };
        const attenuation = self.albedo;
        const is_scattered = true;
        return Scatter{ .attenuation = attenuation, .scattered = scattered, .is_scattered = is_scattered };
    }
};

const Metal = struct {
    albedo: Color,
    fuzz: SType,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, rnd: *RandGen) Scatter {
        const reflected = vec.reflect(vec.unit(r_in.direction), rec.normal);
        const scattered = Ray{ .origin = rec.p, .direction = reflected + f3(self.fuzz) * vec.randomInUnitSphere(rnd, Vec3) };
        const attenuation = self.albedo;
        const is_scattered = vec.dot(scattered.direction, rec.normal) > 0.0;
        return Scatter{ .attenuation = attenuation, .scattered = scattered, .is_scattered = is_scattered };
    }
};

const Dielectric = struct {
    ir: SType,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, rnd: *RandGen) Scatter {
        const attenuation = Color{ 1.0, 1.0, 1.0 };
        const refraction_ratio = if (rec.front_face) (1.0 / self.ir) else self.ir;

        const unit_direction = vec.unit(r_in.direction);
        const cos_theta = math.min(vec.dot(-unit_direction, rec.normal), 1.0);
        const sin_theta = math.sqrt(1.0 - cos_theta * cos_theta);
        const cannot_refract = refraction_ratio * sin_theta > 1.0;

        const direction = switch (cannot_refract or self.reflectance(cos_theta, refraction_ratio) > rtw.getRandom(rnd, @TypeOf(cos_theta))) {
            true => vec.reflect(unit_direction, rec.normal),
            false => vec.refract(unit_direction, rec.normal, refraction_ratio),
        };

        const scattered = Ray{ .origin = rec.p, .direction = direction };
        const is_scattered = true;

        return Scatter{ .attenuation = attenuation, .scattered = scattered, .is_scattered = is_scattered };
    }

    fn reflectance(self: Self, cosine: SType, ref_idx: SType) SType {
        _ = self;
        const r0 = (1.0 - ref_idx) / (1.0 + ref_idx);
        const r0_ = r0 * r0;
        return r0_ + (1.0 - r0_) * math.pow(@TypeOf(cosine), 1.0 - cosine, 5.0);
    }
};
