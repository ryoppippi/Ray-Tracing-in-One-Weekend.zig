const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");
const sphere = @import("sphere.zig");

const ArrayList = std.ArrayList;

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const Sphere = sphere.Sphere;

pub const HittableList = struct {
    objects: ArrayList(Sphere),
    arena: @TypeOf(std.heap.ArenaAllocator.init(std.heap.page_allocator)),
    // original is  std::vector<shared_ptr<hittable>> objects; but we do not use inheritance
    const Self = @This();

    pub fn init() Self {
        var r = Self{
            .objects = undefined,
            .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
        };
        r.objects = ArrayList(Sphere).init(r.arena.allocator());
        return r;
    }

    pub fn deinit(self: *Self) void {
        self.*.arena.deinit();
    }

    pub fn add(self: *Self, s: Sphere) anyerror!*Self {
        try self.*.objects.append(s);
        return self;
    }

    pub fn hit(self: Self, r: Ray, t_min: SType, t_max: SType) HitReturn {
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
        return HitReturn{ .is_hit = hit_anything, .rec = rec };
    }

    const HitReturn: type = struct {
        is_hit: bool,
        rec: HitRecord,
    };
};
