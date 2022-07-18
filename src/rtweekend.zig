const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");

const expectEqual = std.testing.expectEqual;

pub const Vec3 = @Vector(3, f64);
pub const Point3 = Vec3;
pub const Color = Vec3;
pub const SType = vec.vtype(Vec3);

pub inline fn f3(n: anytype) Vec3 {
    return vec.full(Vec3, n);
}

pub const infinity = math.floatMax(SType);
