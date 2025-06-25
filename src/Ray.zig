const Vec3 = @import("utils.zig").Vec3;
const Color = @import("Color.zig").Color;
const normalize = @import("utils.zig").normalize;
const dot = @import("utils.zig").dot;
const std = @import("std");
const math = std.math;
const Hittable = @import("Hittable.zig").Hittable;
const HitRecord = @import("Hittable.zig").HitRecord;
const Interval = @import("utils.zig").Interval;
const randomOnSphere = @import("utils.zig").randomOnSphere;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3,

    pub fn init(origin: Vec3, direction: Vec3) Ray {
        return Ray{
            .origin = origin,
            .direction = direction,
        };
    }

    pub inline fn at(self: Ray, t: f64) Vec3 {
        const vect = Vec3{ t, t, t };
        return self.origin + vect * self.direction;
    }

    pub inline fn lengthSquared(self: Ray) f64 {
        return dot(self.direction, self.direction);
    }

    pub fn rayColor(self: Ray, rand: std.Random, world: *Hittable, depth: u8) Vec3 {
        if (depth <= 0) return Vec3{ 0, 0, 0 };
        var rec = HitRecord.init(self.origin, self.direction, 0, false);
        var interval = Interval.init(0.001, math.floatMax(f64));
        if (world.hit(&self, &interval, &rec)) {
            const dir = randomOnSphere(rand, rec.normal) + rec.normal;
            const ray = Ray.init(rec.p, dir);
            return @as(Vec3, @splat(0.5)) * ray.rayColor(rand, world, depth - 1);
        }
        const unitDirection = normalize(self.direction);
        const a = @as(Vec3, @splat(0.5)) * (@as(Vec3, @splat(unitDirection[1] + 1)));
        return (@as(Vec3, @splat(1)) - a) * @as(Vec3, @splat(1)) + a * Vec3{ 0.5, 0.7, 1.0 };
    }

    pub inline fn nearZero(self: Ray) bool {
        const s = 1e-8;
        return (@abs(self.direction[0]) < s and @abs(self.direction[1]) < s and @abs(self.direction[2]) < s);
    }
};
