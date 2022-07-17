const std = @import("std");
const math = std.math;

const expectEqual = std.testing.expectEqual;

pub fn vsize(comptime v: anytype) comptime_int {
    const T = @TypeOf(v);
    return @typeInfo(T).Vector.len;
}

pub fn vtype(comptime v: anytype) type {
    const T = @TypeOf(v);
    return @typeInfo(T).Vector.child;
}

pub fn vlen(comptime v: anytype) vtype(v) {
    if (vsize(v) == 0) {
        return 0;
    }
    return math.sqrt(vlenSquared(v));
}

pub fn vlenSquared(comptime v: anytype) vtype(v) {
    if (vsize(v) == 0) {
        return 0;
    }
    return @reduce(.Add, v * v);
}

pub fn dot(comptime v1: anytype, comptime v2: anytype) @TypeOf(v1) {
    if (vsize(v1) == 0 or vsize(v2) == 0) {
        return 0;
    }
    return v1 * v2;
}

pub fn cross3(comptime v1: anytype, comptime v2: anytype) @TypeOf(v1) {
    if (vsize(v1) != 3 or vsize(v2) != 3) {
        @compileError("cross3: vectors must be 3-dimensional");
    }
    return @TypeOf(v1){
        v1[1] * v2[2] - v1[2] * v2[1],
        v1[2] * v2[0] - v1[0] * v2[2],
        v1[0] * v2[1] - v1[1] * v2[0],
    };
}

pub fn unit(comptime v: anytype) @TypeOf(v) {
    if (vsize(v) == 0) {
        return 0;
    }
    return v / @splat(vsize(v), vlen(v));
}

test "vector vsize" {
    const v1 = @Vector(1, f32){5};
    try expectEqual(1, vsize(v1));

    const v2 = @Vector(2, f32){ 5, 5 };
    try expectEqual(2, vsize(v2));
}

test "vector vlen" {
    const v1 = @Vector(1, f32){5};
    try expectEqual(@as(vtype(v1), math.sqrt(5 * 5)), vlen(v1));

    const v2 = @Vector(2, f32){ 2, 2 };
    try expectEqual(math.sqrt(@as(vtype(v2), (2 * 2 + 2 * 2))), vlen(v2));
}

test "vector vtype" {
    const v1 = @Vector(1, f32){5};
    try expectEqual(f32, vtype(v1));

    const v2 = @Vector(3, i8){ 5, 3, 4 };
    try expectEqual(i8, vtype(v2));
}

test "vector dot" {
    const v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    const answer = @Vector(3, f32){ 1, 10, 21 };
    try expectEqual(answer, dot(v1, v2));
}

test "vector cross" {
    const v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    const answer = @Vector(3, f32){ -1, -4, 3 };
    try expectEqual(answer, cross3(v1, v2));
}

test "vector unit" {
    const v1 = @Vector(1, f32){3};
    const answer = @Vector(1, f32){1};
    try expectEqual(answer, unit(v1));

    const v2 = @Vector(3, f64){ 1, 2, 3 };
    const l = math.sqrt(@as(f64, 1 * 1 + 2 * 2 + 3 * 3));
    const answer2 = @Vector(3, f64){
        1 / l,
        2 / l,
        3 / l,
    };
    try expectEqual(answer2, unit(v2));
}
