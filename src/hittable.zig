const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const material = @import("material.zig");
const sphere = @import("sphere.zig");

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const Ray = ray.Ray;
const Material = material.Material;
const Sphere = sphere.Sphere;

const dot = vec.dot;

pub const ReturnHitStruct = struct {
    is_hit: bool,
    rec: HitRecord,
};

pub const Hittable = union(enum) {
    Sphere: Sphere,

    const Self = @This();

    pub fn hit(self: Self, r: Ray, t_min: SType, t_max: SType) ReturnHitStruct {
        return switch (self) {
            .Sphere => |s| s.hit(r, t_min, t_max),
        };
    }

    pub fn sphere(center: Point3, radius: SType, mat: Material) Hittable {
        return Hittable{ .Sphere = Sphere{ .center = center, .radius = radius, .mat = mat } };
    }
};

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    mat: Material,
    t: SType,
    front_face: bool,
    const Self = @This();

    pub fn set_face_normal(self: *Self, r: Ray, outward_normal: Vec3) void {
        self.*.front_face = dot(r.direction, outward_normal) < 0;
        self.*.normal = if (self.front_face) outward_normal else -outward_normal;
    }
};
