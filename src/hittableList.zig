const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const sphere = @import("sphere.zig");

const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const Sphere = sphere.Sphere;

pub const HittableList = struct {
    objects: ArrayList(Sphere),
    // original is  std::vector<shared_ptr<hittable>> objects; but we do not use inheritance
    const Self = @This();

    pub fn init() Self {
        return Self{ .objects = ArrayList(Sphere).init(test_allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.*.objects.deinit();
    }

    pub fn add(self: *Self, s: Sphere) anyerror!*Self {
        try self.*.objects.append(s);
        return self;
    }

    pub fn hit(self: *Self, r: Ray, t_min: SType, t_max: SType, rec: *HitRecord) bool {
        var temp_rec: HitRecord = undefined;
        var hit_anything: bool = false;
        var closest_so_far = t_max;

        for (self.*.objects.items) |object| {
            if (object.hit(r, t_min, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        return hit_anything;
    }

    pub fn clear() void {}
};
