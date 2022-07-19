const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");

const Vec3 = rtw.Vec3;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const RandGen = rtw.RandGen;
const Ray = ray.Ray;

const f3 = rtw.f3;

pub const Camera = struct {
    origin: Point3,
    lower_left_corner: Point3,
    horizontal: Vec3,
    vertical: Vec3,
    u: Vec3,
    v: Vec3,
    w: Vec3,
    lens_radius: SType,

    const Self = @This();

    pub fn init(
        lookfrom: Point3,
        lookat: Point3,
        vup: Vec3,
        vfov: SType, // vertical field-of-view in degrees
        aspect_ratio: SType,
        aperture: SType,
        focus_dist: SType,
    ) Self {
        const theta = vfov * math.pi / 180.0; // degrees to radians
        const h = math.tan(theta / 2);
        const viewport_height = 2.0 * h;
        const viewport_width = aspect_ratio * viewport_height;

        const w = vec.unit(lookfrom - lookat);
        const u = vec.unit(vec.cross3(vup, w));
        const v = vec.cross3(w, u);

        const origin = lookfrom;
        const horizontal = f3(focus_dist) * f3(viewport_width) * u;
        const vertical = f3(focus_dist) * f3(viewport_height) * v;
        const lower_left_corner = origin - (horizontal / f3(2.0)) - (vertical / f3(2.0)) - f3(focus_dist) * w;

        const lens_radius = aperture / 2.0;

        return Self{
            .origin = origin,
            .horizontal = horizontal,
            .vertical = vertical,
            .lower_left_corner = lower_left_corner,
            .u = u,
            .v = v,
            .w = w,
            .lens_radius = lens_radius,
        };
    }
    pub fn getRay(self: Self, s: SType, t: SType, rnd: *RandGen) Ray {
        const rd = f3(self.lens_radius) * vec.randomInUnitDisk3(Vec3, rnd);
        const offset = self.u * f3(rd[0]) + self.v * f3(rd[1]);
        return Ray{
            .origin = self.origin + offset,
            .direction = self.lower_left_corner + f3(s) * self.horizontal + f3(t) * self.vertical - self.origin - offset,
        };
    }
};
