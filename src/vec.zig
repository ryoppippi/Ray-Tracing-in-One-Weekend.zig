const std = @import("std");
const math = std.math;

const expectEqual = std.testing.expectEqual;

pub fn vsize(comptime T: type) comptime_int {
    _ = ensureVector(T);
    return @typeInfo(T).Vector.len;
}

pub fn vtype(comptime T: type) type {
    _ = ensureVector(T);
    return @typeInfo(T).Vector.child;
}

pub fn vlen(v: anytype) vtype(@TypeOf(v)) {
    _ = ensureVector(@TypeOf(v));
    return math.sqrt(dot(v, v));
}

pub fn dot(v1: anytype, v2: anytype) vtype(@TypeOf(v1)) {
    const vt1 = ensureVector(@TypeOf(v1));
    const vt2 = ensureVector(@TypeOf(v2));
    if (vt1 != vt2) {
        @compileError("dot: vectors must be of the same type");
    }

    return @reduce(.Add, v1 * v2);
}

pub fn cross3(v1: anytype, v2: anytype) @TypeOf(v1) {
    const vt1 = ensureVector(@TypeOf(v1));
    const vt2 = ensureVector(@TypeOf(v2));
    if (vsize(vt1) != 3 or vsize(vt2) != 3) {
        @compileError("cross3: vectors must be 3-dimensional");
    }
    return vt1{
        v1[1] * v2[2] - v1[2] * v2[1],
        v1[2] * v2[0] - v1[0] * v2[2],
        v1[0] * v2[1] - v1[1] * v2[0],
    };
}

pub fn unit(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    return v / full(T, vlen(v));
}

pub fn full(comptime T: type, n: anytype) T {
    const vs = vsize(ensureVector(T));
    const vt = vtype(T);
    const nT = @TypeOf(n);
    switch (@typeInfo(nT)) {
        .ComptimeFloat, .Float, .ComptimeInt, .Int => {
            return @splat(vs, @as(vt, n));
        },
        else => @compileError("not implemented for " ++ @typeName(nT)),
    }
}

fn ensureVector(comptime T: type) type {
    const info = @typeInfo(T);
    if (info != .Vector) {
        @compileError("assertIsTypeVector: type is not a vector");
    }
    return T;
}

test "vector vsize" {
    const v1 = @Vector(1, f32){5};
    try expectEqual(1, vsize(@TypeOf(v1)));

    const v2 = @Vector(2, f32){ 5, 5 };
    try expectEqual(2, vsize(@TypeOf(v2)));
}

test "immutable vector vsize" {
    var v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    v1 += v2;
    try expectEqual(3, vsize(@TypeOf(v1)));
}

test "vector vlen" {
    const v1 = @Vector(1, f32){5};
    try expectEqual(@as(vtype(@TypeOf(v1)), math.sqrt(5 * 5)), vlen(v1));

    const v2 = @Vector(2, f32){ 2, 2 };
    try expectEqual(math.sqrt(@as(vtype(@TypeOf(v2)), (2 * 2 + 2 * 2))), vlen(v2));
}

test "immutable vector vlen" {
    var v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    v1 += v2;
    try expectEqual(math.sqrt(@as(vtype(@TypeOf(v1)), (2 * 2 + 7 * 7 + 10 * 10))), vlen(v1));
}

test "vector vtype" {
    const v1 = @Vector(1, f32){5};
    try expectEqual(f32, vtype(@TypeOf(v1)));

    const v2 = @Vector(3, i8){ 5, 3, 4 };
    try expectEqual(i8, vtype(@TypeOf(v2)));
}

test "immutable vector vtype" {
    var v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    v1 += v2;
    try expectEqual(f32, vtype(@TypeOf(v1)));
}

test "vector dot" {
    const v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    const answer = @as(vtype(@TypeOf(v1)), (1 * 1 + 2 * 5 + 3 * 7));
    try expectEqual(answer, dot(v1, v2));
}

test "immutable vector dot" {
    var v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    v1 += v2;
    const answer = @as(vtype(@TypeOf(v1)), (1 * (1 + 1) + 5 * (2 + 5) + 7 * (3 + 7)));
    try expectEqual(answer, dot(v1, v2));
}

test "vector cross" {
    const v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    const answer = @Vector(3, f32){ -1, -4, 3 };
    try expectEqual(answer, cross3(v1, v2));
}

test "immutable vector cross" {
    var v1 = @Vector(3, f32){ 0, 0, 0 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    const dummy = @Vector(3, f32){ 1, 2, 3 };
    v1 += dummy;
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

test "immutable vector unit" {
    var v1 = @Vector(1, f32){3};
    const answer = @Vector(1, f32){1};
    v1 += @Vector(1, f32){0};
    try expectEqual(answer, unit(v1));

    var v2 = @Vector(3, f64){ 1, 2, 3 };
    const l = math.sqrt(@as(f64, 1 * 1 + 2 * 2 + 3 * 3));
    const answer2 = @Vector(3, f64){
        1 / l,
        2 / l,
        3 / l,
    };
    v2 += @Vector(3, f64){ 0, 0, 0 };
    try expectEqual(answer2, unit(v2));
}
