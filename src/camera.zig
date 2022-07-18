const std = @import("std");
const math = @import("math");
const rtw = @import("rtweekend.zig");
const ray = @import("ray.zig");

const Vec3 = rtw.Vec3;
const Point3 = rtw.Point3;
const SType = rtw.SType;
const Ray = ray.Ray;

const f3 = rtw.f3;

pub const Camera = struct {
    aspect_ratio: SType,
    viewport_height: SType,
    viewport_width: SType,
    focal_length: SType,

    origin: Point3,
    lower_left_corner: Point3,
    horizontal: Vec3,
    vertical: Vec3,

    const Self = @This();

    pub fn init() Self {
        const aspect_ratio = 16.0 / 9.0;
        const viewport_height = 2.0;
        const viewport_width = aspect_ratio * viewport_height;
        const focal_length = 1.0;

        const origin = Point3{ 0.0, 0.0, 0.0 };
        const horizontal = Vec3{ viewport_width, 0.0, 0.0 };
        const vertical = Vec3{ 0.0, viewport_height, 0.0 };
        const lower_left_corner = origin - (horizontal / f3(2.0)) - (vertical / f3(2.0)) - Vec3{ 0.0, 0.0, focal_length };

        return Self{
            .aspect_ratio = aspect_ratio,
            .viewport_height = viewport_height,
            .viewport_width = viewport_width,
            .focal_length = focal_length,
            .origin = origin,
            .horizontal = horizontal,
            .vertical = vertical,
            .lower_left_corner = lower_left_corner,
        };
    }
    pub fn getRay(self: Self, u: SType, v: SType) Ray {
        return Ray{ .origin = self.origin, .direction = self.lower_left_corner + f3(u) * self.horizontal + f3(v) * self.vertical - self.origin };
    }
};
