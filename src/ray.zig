const vec = @import("vec.zig");

const Point3 = vec.Point3;
const Vec3 = vec.Vec3;
const f3 = vec.f3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,
    const Self = @This();

    pub fn at(self: Self, t: anytype) Point3 {
        return self.origin + f3(t) * self.direction;
    }
};
