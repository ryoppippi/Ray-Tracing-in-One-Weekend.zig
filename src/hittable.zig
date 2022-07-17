const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");
const ray = @import("ray.zig");

const Vec3 = vec.Vec3;
const Color = vec.Color;
const Point3 = vec.Point3;
const Ray = ray.Ray;

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool,
    const Self = @This();

    pub fn set_face_normal(self: Self, r: Ray, outward_normal: Vec3) bool {
        self.front_face = dot(r.direction(), outward_normal) < 0;
        self.normal = if (self.forward_face) outward_normal else -outward_normal;
    }
};

// not implement hittable
