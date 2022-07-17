const vec = @import("vec.zig");

const Point3 = vec.Point3;
const Vec3 = vec.Vec3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,
};
pub fn at(ray: Ray, t: anytype) Point3 {
    return ray.origin + @splat(3, t) * ray.direction;
}
