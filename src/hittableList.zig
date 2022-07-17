const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");

const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

const Vec3 = vec.Vec3;
const Color = vec.Color;
const Point3 = vec.Point3;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const Sphere = hittable.Sphere;

pub const HittableList = struct {
    objects: ArrayList(Spehere),
    // original is  std::vector<shared_ptr<hittable>> objects; but we do not use inheritance
    const Self = @This();

    pub fn init(self: Self) Self {
        return self{ .spheres = ArrayList(Sphere).init(test_allocator) };
    }

    pub fn deinit(self: Self) void {
        self.spheres.deinit();
    }

    pub fn add(self: Self, sphere: Sphere) Self {
        self.spheres.append(sphere);
        return self;
    }

    pub fn hit(self: Self, r: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        var temp_rec: ?HitRecord = undefined;
        var hit_anything: bool = false;
        var closest_so_far = t_max;

        for (self.objects.items) |object| {
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
