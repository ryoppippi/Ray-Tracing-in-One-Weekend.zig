const vec = @import("vec.zig");

const Point3 = vec.Point3;
const Vec3 = vec.Vec3;

pub const ray = struct {
    origin: Point3,
    direction: Vec3,
    const Self = @This();

    fn init(origin: Point3, direction: Vec3) void {
        return Self{ .origin = origin, .direction = direction };
    }

    fn getOrigin(self: Self) Point3 {
        return self.origin;
    }
    fn getDirection(self: Self) @Vector(3, f64) {
        return self.direction;
    }
    fn at(self: Self, t: comptime_float) Point3 {
        return self.origin + t * self.direction;
    }
};
