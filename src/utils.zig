const std = @import("std");
const math = std.math;

pub const RandGen = std.rand.DefaultPrng;

pub fn degreeToRadian(degree: SType) comptime_float {
    return degree * math.pi / 180.0;
}

var rnd = RndGen.init(0);
pub fn get_random(T: type) @TypeOf(T) {
    return switch (@typeInfo(T)) {
        .ComptimeFloat, .Float => rnd.random().float(T),
        .ComptimeInt, .Int => return rnd.random().int(T),
        else => @compileError("not implemented for " ++ @typeName(T)),
    };
}
