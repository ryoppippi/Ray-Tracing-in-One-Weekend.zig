const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");

const ArrayList = std.ArrayList;

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const Ray = ray.Ray;
const Hittable = hittable.Hittable;
const HitRecord = hittable.HitRecord;

pub const HittableList = struct {
    objects: ArrayList(Hittable),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{ .objects = ArrayList(Hittable).init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.*.objects.deinit();
    }

    pub fn add(self: *Self, s: Hittable) anyerror!*Self {
        try self.*.objects.append(s);
        return self;
    }

    pub fn hit(self: Self, r: Ray, t_min: SType, t_max: SType) struct {
        is_hit: bool,
        rec: HitRecord,
    } {
        var rec: HitRecord = undefined;
        var hit_anything: bool = false;
        var closest_so_far = t_max;

        for (self.objects.items) |object| {
            const temp_hit = object.hit(r, t_min, closest_so_far);
            const temp_rec = temp_hit.rec;
            if (temp_hit.is_hit) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec = temp_rec;
            }
        }
        return .{ .is_hit = hit_anything, .rec = rec };
    }
};
