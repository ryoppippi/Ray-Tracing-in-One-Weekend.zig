const vec = @import("vec.zig");
const rtw = @import("rtweekend.zig");

const Point3 = rtw.Point3;
const Vec3 = rtw.Vec3;
const f3 = rtw.f3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,
    const Self = @This();

    pub fn at(self: Self, t: anytype) Point3 {
        return self.origin + f3(t) * self.direction;
    }
};
