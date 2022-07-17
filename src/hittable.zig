const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");
const ray = @import("ray.zig");

const Vec3 = vec.Vec3;
const Color = vec.Color;
const Point3 = vec.Point3;
const Ray = ray.Ray;

const dot = vec.dot;

pub const hitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool,
    const Self = This();
    pub fn set_face_normal(self: Self, ray: Ray, outward_normal: Vec3) bool {
        self.front_face = dot(r.direction(), outward_normal) < 0;
        self.normal = if (forward_face) outward_normal else -outward_normal;
    }
};

pub const Sphere = struct {
    center: Point3,
    radius: f64,
    const Self = @This();

    pub fn hit(
        self: Self,
        r: Ray,
        tMin: f64,
        tMax: f64,
        rec: hitRecord,
    ) bool {
        const oc = r.origin - self.center;
        const a = dot(r.direction, r.direction);
        const half_b = dot(oc, r.direction);
        const c = dot(oc, oc) - self.radius * self.radius;
        const discriminant = half_b * half_b - a * c;

        if (discriminant > 0) {
            const root = math.sqrt(discriminant);
            const temp1 = (-half_b - root) / a;
            if (temp1 < tMax and temp1 > tMin) {
                rec.t = temp1;
                rec.p = r.at(rec.t);
                const outward_normal = (rec.p - center) / radius;
                rec.set_face_normal(r, outward_normal);
                rec.normal = (rec.p - self.center) / self.radius;
                return true;
            }
            const temp2 = (-half_b + root) / a;
            if (temp2 < tMax and temp2 > tMin) {
                rec.t = temp2;
                rec.p = r.at(rec.t);
                const outward_normal = (rec.p - center) / radius;
                rec.set_face_normal(r, outward_normal);
                rec.normal = (rec.p - self.center) / self.radius;
                return true;
            }
        }
        return false;
    }
};
