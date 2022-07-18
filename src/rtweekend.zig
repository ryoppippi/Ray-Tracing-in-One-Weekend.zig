const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");

pub const Vec3 = @Vector(3, f64);
pub const Point3 = Vec3;
pub const Color = Vec3;
pub const SType = vec.vtype(Vec3);
pub fn f3(n: anytype) Vec3 {
    return vec.full(Vec3, n);
}

pub const infinity = math.floatMax(SType);

pub const pi = 3.14159265358979323846;

pub fn degreeToRadian(degree: SType) SType {
    return degree * pi / 180.0;
}
