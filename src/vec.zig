const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");

const RandGen = rtw.RandGen;

pub inline fn vsize(comptime T: type) comptime_int {
    _ = ensureVector(T);
    return @typeInfo(T).Vector.len;
}

pub inline fn vtype(comptime T: type) type {
    _ = ensureVector(T);
    return @typeInfo(T).Vector.child;
}

pub inline fn len(v: anytype) vtype(@TypeOf(v)) {
    _ = ensureVector(@TypeOf(v));
    return math.sqrt(dot(v, v));
}

pub inline fn dot(v1: anytype, v2: anytype) vtype(@TypeOf(v1)) {
    const vt1 = ensureVector(@TypeOf(v1));
    const vt2 = ensureVector(@TypeOf(v2));
    if (vt1 != vt2) {
        @compileError("dot: vectors must be of the same type");
    }

    return @reduce(.Add, v1 * v2);
}

pub inline fn cross3(v1: anytype, v2: anytype) @TypeOf(v1) {
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

pub inline fn unit(v: anytype) @TypeOf(v) {
    const T = @TypeOf(v);
    return v / full(T, len(v));
}

pub inline fn full(comptime T: type, n: anytype) T {
    const vs = vsize(ensureVector(T));
    const vt = vtype(T);
    const nT = @TypeOf(n);
    return switch (@typeInfo(nT)) {
        .ComptimeFloat, .Float, .ComptimeInt, .Int => @splat(vs, @as(vt, n)),
        else => @compileError("not implemented for " ++ @typeName(nT)),
    };
}

pub inline fn randomVec(rnd: *RandGen, comptime T: type) T {
    _ = ensureVector(T);
    const vs = vsize(T);
    const vt = vtype(T);
    var dummy = full(T, 0);
    var i: u32 = 0;
    while (i < vs) : (i += 1) {
        dummy[i] = rtw.getRandom(rnd, vt);
    }
    return dummy;
}

pub inline fn randomInUnitSphere(rnd: *RandGen, comptime T: type) T {
    while (true) {
        const p = randomVec(rnd, T);
        if (dot(p, p) > 1.0) continue;
        return p;
    }
}

pub inline fn randomUnitVector(rnd: *RandGen, comptime T: type) T {
    const vt = vtype(T);
    const a = rtw.getRandomInRange(rnd, vt, 2, math.pi);
    const z = rtw.getRandomInRange(rnd, vt, -1, 1);
    const r = math.sqrt(1 - z * z);
    return T{ r * math.cos(a), r * math.sin(a), z };
}

pub inline fn randomInHemisphere(rnd: *RandGen, comptime T: type) T {
    const in_unit_sphere = randomInUnitSphere(rnd, T);
    if (dot(in_unit_sphere, in_unit_sphere) > 0.0) {
        return in_unit_sphere;
    } else {
        return -in_unit_sphere;
    }
}

pub inline fn reflect(v: anytype, n: anytype) @TypeOf(v) {
    const T = ensureVector(@TypeOf(v));
    const nT = ensureVector(@TypeOf(n));
    if (T != nT) {
        @compileError("reflect: vectors must be of the same type");
    }
    return v - full(T, 2 * dot(v, n)) * n;
}

pub inline fn nearZero(v: anytype) bool {
    const T = ensureVector(@TypeOf(v));
    const vsT = vtype(T);
    const s = 1e-8;
    // return @reduce(.And,  @fabs(v) < s); // it does not compile on my M1 mac https://github.com/ziglang/zig/issues/12169
    return switch (@typeInfo(vsT)) {
        .ComptimeFloat, .Float => {
            {
                const abs_v = @fabs(v);
                var i: u32 = 0;
                while (i < vsize(T)) : (i += 1) {
                    if (abs_v[i] > s) return false;
                }
                return true;
            }
        },
        else => @compileError("not implemented for " ++ @typeName(vsT)),
    };
}

pub inline fn refract(uv: anytype, n: anytype, etai_over_etat: anytype) @TypeOf(uv) {
    const uvT = ensureVector(@TypeOf(uv));
    const nT = ensureVector(@TypeOf(n));
    if (uvT != nT) {
        @compileError("refract: vectors must be of the same type");
    }
    const etaT = @TypeOf(etai_over_etat);
    const uvTs = vtype(uvT);
    if (etaT != uvTs) {
        @compileError("refract: eta and num type of uv must be of the same type");
    }

    const abs = switch (@typeInfo(etaT)) {
        .ComptimeFloat, .Float => math.fabs,
        .ComptimeInt, .Int => math.absInt,
        else => @compileError("not implemented for " ++ @typeName(etaT)),
    };

    const cos_theta = math.min(dot(-uv, n), 1.0);
    const r_out_perp = full(uvT, etai_over_etat) * (uv + full(uvT, cos_theta) * n);
    const r_out_parallel = full(uvT, -math.sqrt(abs(1.0 - dot(r_out_perp, r_out_perp)))) * n;
    return r_out_parallel + r_out_perp;
}

inline fn ensureVector(comptime T: type) type {
    if (@typeInfo(T) != .Vector) {
        @compileError("ensureIsTypeVector: type is not a vector");
    }
    return T;
}

pub inline fn randomInUnitDisk3(comptime T: type, rnd: *RandGen) T {
    _ = ensureVector(T);
    if (vsize(T) != 3) {
        @compileError("randomInUnitDisk3: vector must be 3-dimensional");
    }
    while (true) {
        const p = T{
            rtw.getRandomInRange(rnd, vtype(T), -1, 1),
            rtw.getRandomInRange(rnd, vtype(T), -1, 1),
            0.0,
        };
        if (dot(p, p) >= 1.0) continue;
        return p;
    }
}

const expectEqual = std.testing.expectEqual;
const expect = @import("std").testing.expect;

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

test "vector len" {
    const v1 = @Vector(1, f32){5};
    try expectEqual(@as(vtype(@TypeOf(v1)), math.sqrt(5 * 5)), len(v1));

    const v2 = @Vector(2, f32){ 2, 2 };
    try expectEqual(math.sqrt(@as(vtype(@TypeOf(v2)), (2 * 2 + 2 * 2))), len(v2));
}

test "immutable vector len" {
    var v1 = @Vector(3, f32){ 1, 2, 3 };
    const v2 = @Vector(3, f32){ 1, 5, 7 };
    v1 += v2;
    try expectEqual(math.sqrt(@as(vtype(@TypeOf(v1)), (2 * 2 + 7 * 7 + 10 * 10))), len(v1));
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

test "ensureVector" {
    const v1 = @Vector(1, f32){3};
    const T1 = @TypeOf(v1);
    const T2 = ensureVector(T1);
    try expectEqual(T1, T2);
}

test "nearZero" {
    const v1 = @Vector(1, f32){0};
    try expectEqual(true, nearZero(v1));

    const v2 = @Vector(3, f64){ 0, 0, 1e-10 };
    try expectEqual(true, nearZero(v2));

    var v3 = @Vector(3, f64){ 0, 2, 1e-10 };
    try expectEqual(false, nearZero(v3));
}
