const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const material = @import("material.zig");

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const Material = material.Material;

const dot = vec.dot;
const f3 = rtw.f3;

pub const Sphere = struct {
    center: Point3,
    radius: SType,
    mat: Material,
    const Self = @This();

    pub fn hit(
        self: Self,
        r: Ray,
        t_min: SType,
        t_max: SType,
    ) ReturnS {
        var rec: HitRecord = undefined;

        const oc = r.origin - self.center;
        const a = dot(r.direction, r.direction);
        const half_b = dot(oc, r.direction);
        const c = dot(oc, oc) - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) return false_return;
        const sqrtd = math.sqrt(discriminant);

        var root = (-half_b - sqrtd) / a;
        if (root < t_min or t_max < root) {
            root = (-half_b + sqrtd) / a;
            if (root < t_min or t_max < root) {
                return false_return;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        rec.normal = (rec.p - self.center) / f3(self.radius);
        rec.mat = self.mat;

        const outward_normal: Vec3 = (rec.p - self.center) / f3(self.radius);
        _ = rec.set_face_normal(r, outward_normal);

        return ReturnS{ .is_hit = true, .rec = rec };
    }

    const ReturnS = struct {
        is_hit: bool,
        rec: HitRecord,
    };
    const false_return = ReturnS{ .is_hit = false, .rec = undefined };
};
