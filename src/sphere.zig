const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");

const Vec3 = vec.Vec3;
const Color = vec.Color;
const Point3 = vec.Point3;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;

const dot = vec.dot;

pub const Sphere = struct {
    center: Point3,
    radius: f64,
    const Self = @This();

    pub fn hit(
        self: Self,
        r: Ray,
        tMin: f64,
        tMax: f64,
        rec: HitRecord,
    ) bool {
        const oc = r.origin - self.center;
        const a = dot(r.direction, r.direction);
        const half_b = dot(oc, r.direction);
        const c = dot(oc, oc) - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) return false;

        const sqrtd = math.sqrt(discriminant);

        var root = (-half_b - math.sqrt(discriminant)) / a;
        if (root < tMax and root > tMin) {
            root = (-half_b + sqrtd) / a;
            if (root < tMax or root > tMin) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        rec.normal = (rec.p - self.center) / self.radius;

        const outward_normal = (rec.p - self.center) / self.radius;
        rec.set_face_normal(r, outward_normal);

        return true;
    }
};
