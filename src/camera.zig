const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");

const Vec3 = rtw.Vec3;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const Ray = ray.Ray;

const f3 = rtw.f3;

pub const Camera = struct {
    origin: Point3,
    lower_left_corner: Point3,
    horizontal: Vec3,
    vertical: Vec3,

    const Self = @This();

    pub fn init(
        lookfrom: Point3,
        lookat: Point3,
        vup: Vec3,
        vfov: SType, // vertical field-of-view in degrees
        aspect_ratio: SType,
    ) Self {
        const theta = vfov * math.pi / 180.0; // degrees to radians
        const h = math.tan(theta / 2);
        const viewport_height = 2.0 * h;
        const viewport_width = aspect_ratio * viewport_height;

        const w = vec.unit(lookfrom - lookat);
        const u = vec.unit(vec.cross3(vup, w));
        const v = vec.cross3(w, u);

        const origin = lookfrom;
        const horizontal = f3(viewport_width) * u;
        const vertical = f3(viewport_height) * v;
        const lower_left_corner = origin - (horizontal / f3(2.0)) - (vertical / f3(2.0)) - w;

        return Self{
            .origin = origin,
            .horizontal = horizontal,
            .vertical = vertical,
            .lower_left_corner = lower_left_corner,
        };
    }
    pub fn getRay(self: Self, s: SType, t: SType) Ray {
        return Ray{ .origin = self.origin, .direction = self.lower_left_corner + f3(s) * self.horizontal + f3(t) * self.vertical - self.origin };
    }
};
