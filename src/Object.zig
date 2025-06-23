const Vec3 = @import("utils.zig").Vec3;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("Hittable.zig").HitRecord;
const dot = @import("utils.zig").dot;
const std = @import("std");
const math = std.math;
const Interval = @import("utils.zig").Interval;

pub const Sphere = struct {
    center: Vec3,
    radius: f32,

    pub fn init(center: Vec3, radius: f32) Sphere {
        return Sphere{
            .center = center,
            .radius = radius,
        };
    }

    pub inline fn hit(self: Sphere, ray: *const Ray, rayT: Interval, rec: *HitRecord) bool {
        const oc = self.center - ray.origin;
        const a = dot(ray.direction, ray.direction);
        const h = dot(ray.direction, oc);
        const c = dot(oc, oc) - self.radius * self.radius;

        const discriminant = h * h - a * c;
        if (discriminant < 0) return false;

        const sqrtd = math.sqrt(discriminant);
        var root = (h - sqrtd) / a;
        if (!rayT.surrounds(root)) {
            root = (h + sqrtd) / a;
            if (!rayT.surrounds(root)) return false;
        }

        rec.t = root;
        rec.p = ray.at(rec.t);
        const outwardNormal = (rec.p - self.center) / @as(Vec3, @splat(self.radius));
        rec.setFaceNormal(ray, outwardNormal);

        return true;
    }
};
