const std = @import("std");
const math = std.math;
const vec = @import("vec.zig");

const expectEqual = std.testing.expectEqual;

pub const Vec3 = @Vector(3, f32);
pub const Point3 = Vec3;
pub const Color = Vec3;
pub const SType = vec.vtype(Vec3);

pub const RandGen = std.rand.DefaultPrng;

pub inline fn f3(n: anytype) Vec3 {
    return vec.full(Vec3, n);
}

pub fn getInfinity(comptime T: type) T {
    return switch (@typeInfo(T)) {
        .ComptimeFloat, .Float => math.floatMax(T),
        .ComptimeInt, .Int => math.maxInt(T),
        else => @compileError("not implemented for " ++ @typeName(T)),
    };
}

pub fn getRandom(rnd: *RandGen, comptime T: type) T {
    return switch (@typeInfo(T)) {
        .ComptimeFloat, .Float => rnd.*.random().float(T),
        .ComptimeInt, .Int => return rnd.*.random().int(T),
        else => @compileError("not implemented for " ++ @typeName(T)),
    };
}

pub fn getRandomInRange(rnd: *RandGen, comptime T: type, min: T, max: T) T {
    return getRandom(rnd, T) * (max - min) + min;
}

pub fn clamp(x: SType, min: SType, max: SType) SType {
    return if (x < min) min else if (x > max) max else x;
}

test "random" {
    const expect = std.testing.expect;
    const print = std.debug.print;
    var i: u32 = 0;
    var rnd = RandGen.init(0);
    while (i < 10) {
        const a = getRandom(&rnd, SType);
        print("{}\n", .{a});
        try expect(a <= 1);
        try expect(a >= 0);
        i += 1;
    }
}

test "randomInRange" {
    const expect = std.testing.expect;
    const print = std.debug.print;
    var i: u32 = 0;
    var rnd = RandGen.init(0);
    while (i < 10) {
        const a = getRandomInRange(&rnd, SType, -2, -1);
        print("{}\n", .{a});
        try expect(a <= -1);
        try expect(a >= -2);
        i += 1;
    }
}
