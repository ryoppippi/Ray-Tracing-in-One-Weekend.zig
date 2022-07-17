const std = @import("std");
const math = std.math;

const expectEqual = std.testing.expectEqual;

fn Vec(
    comptime size: comptime_int,
    comptime T: type,
) type {
    return struct {
        data: @Vector(size, T),
        size: comptime_int,
        const Self = @This();

        fn init(data: [size]T) Self {
            return Self{ .data = data, .size = size };
        }

        fn print(comptime self: Self) noreturn {
            const dprint = std.debug.print;
            dprint("{}\n", .{self.data});
        }

        fn size(comptime self: Self) comptime_int {
            return self.size;
        }

        fn len(comptime self: Self) T {
            return math.sqrt(self.len_sqred());
        }

        fn len_sqred(comptime self: Self) T {
            if (self.size == 0) {
                return 0;
            }
            return @reduce(.Add, self.data * self.data);
        }

        fn unit_vector(comptime self: Self) Vec(self.size, T) {
            return self / self.len();
        }

        fn dot(comptime self: Self, v2: Self) Self {
            return Self{ .data = self.data * v2.data, .size = self.size };
        }

        fn cross3(comptime self: Self, v2: Self) Self {
            if (self.size != 3 or v2.size != 3) {
                @compileError("'cross3' only works on 3-vectors");
            }
            return Self{
                .data = @Vector(3, T){
                    self.data[1] * v2.data[2] - self.data[2] * v2.data[1],
                    self.data[2] * v2.data[0] - self.data[0] * v2.data[2],
                    self.data[0] * v2.data[1] - self.data[1] * v2.data[0],
                },
                .size = 3,
            };
        }

        fn add(comptime self: Self, v2: anytype) Self {
            if (@TypeOf(v2) == Vec(self.size, T)) {
                return Self{ .data = self.data + v2.data, .size = self.size };
            } else {
                return Self{ .data = self.data + @splat(self.size, @as(T, v2)), .size = self.size };
            }
        }

        fn sub(comptime self: Self, v2: anytype) Self {
            if (@TypeOf(v2) == Vec(self.size, T)) {
                return Self{ .data = self.data - v2.data, .size = self.size };
            } else {
                return Self{ .data = self.data - @splat(self.size, @as(T, v2)), .size = self.size };
            }
        }

        fn mul(comptime self: Self, v2: anytype) Self {
            if (@TypeOf(v2) == Vec(self.size, T)) {
                return Self{ .data = self.data * v2.data, .size = self.size };
            } else {
                return Self{ .data = self.data * @splat(self.size, @as(T, v2)), .size = self.size };
            }
        }

        fn div(comptime self: Self, v2: anytype) Self {
            if (@TypeOf(v2) == Vec(self.size, T)) {
                return Self{ .data = self.data / v2.data, .size = self.size };
            } else {
                return Self{ .data = self.data / @splat(self.size, @as(T, v2)), .size = self.size };
            }
        }
    };
}

test "vec_len_size1" {
    const v1 = Vec(1, f32).init(.{5});
    try expectEqual(1, v1.size);
    try expectEqual(math.sqrt(math.pow(f32, 5, 2)), v1.len());
}

test "vec_len_size2" {
    const v2 = Vec(2, f32).init(.{ 5, 7 });
    try expectEqual(2, v2.size);
    try expectEqual(math.sqrt(math.pow(f32, 5, 2) + math.pow(f32, 7, 2)), v2.len());
}

test "vec_dot" {
    const v1 = Vec(2, f32).init(.{ 5, 7 });
    const v2 = Vec(2, f32).init(.{ 3, 4 });
    const answer = @Vector(2, f32){ 5, 7 } * @Vector(2, f32){ 3, 4 };
    try expectEqual(answer, v1.dot(v2).data);
}

test "vec_cross" {
    const v1 = Vec(3, f32).init(.{ 1, 2, 3 });
    const v2 = Vec(3, f32).init(.{ 1, 5, 7 });
    const answer = Vec(3, f32).init(.{ -1, -4, 3 });
    try expectEqual(answer, v1.cross3(v2));
}

test "vec_add_vec" {
    const v1 = Vec(2, f32).init(.{ 5, 7 });
    const v2 = Vec(2, f32).init(.{ 3, 4 });
    const answer = Vec(2, f32).init(.{ 8, 11 });
    try expectEqual(answer, v1.add(v2));
}

test "vec_add_scalar" {
    const v1 = Vec(2, f32).init(.{ 5, 7 });
    const answer = Vec(2, f32).init(.{ 8, 10 });
    try expectEqual(answer, v1.add(3));
}

test "vec_sub_vec" {
    const v1 = Vec(2, f32).init(.{ 5, 7 });
    const v2 = Vec(2, f32).init(.{ 3, 4 });
    const answer = Vec(2, f32).init(.{ 2, 3 });
    try expectEqual(answer, v1.sub(v2));
}

test "vec_sub_scalar" {
    const v1 = Vec(2, f32).init(.{ 5, 7 });
    const answer = Vec(2, f32).init(.{ 2, 4 });
    try expectEqual(answer, v1.sub(3));
}

test "vec_mul_vec" {
    const v1 = Vec(2, f32).init(.{ 5, 7 });
    const v2 = Vec(2, f32).init(.{ 3, 4 });
    const answer = Vec(2, f32).init(.{ 15, 28 });
    try expectEqual(answer, v1.mul(v2));
}

test "vec_mul_scalar" {
    const v1 = Vec(2, f32).init(.{ 5, 7 });
    const answer = Vec(2, f32).init(.{ 15, 21 });
    try expectEqual(answer, v1.mul(3));
}

test "vec_div_vec" {
    const v1 = Vec(2, f32).init(.{ 5, 30 });
    const v2 = Vec(2, f32).init(.{ 2, 20 });
    const answer = Vec(2, f32).init(.{ 2.5, 1.5 });
    try expectEqual(answer, v1.div(v2));
}

test "vec_div_scalar" {
    const v1 = Vec(2, f32).init(.{ 5, 7 });
    const answer = Vec(2, f32).init(.{ 2.5, 3.5 });
    try expectEqual(answer, v1.div(2));
}
