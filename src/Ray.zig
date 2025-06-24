const Vec3 = @import("utils.zig").Vec3;
const Color = @import("Color.zig").Color;
const normalize = @import("utils.zig").normalize;
const dot = @import("utils.zig").dot;
const std = @import("std");
const math = std.math;
const Hittable = @import("Hittable.zig").Hittable;
const HitRecord = @import("Hittable.zig").HitRecord;
const Interval = @import("utils.zig").Interval;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3,

    pub fn init(origin: Vec3, direction: Vec3) Ray {
        return Ray{
            .origin = origin,
            .direction = direction,
        };
    }

    pub inline fn at(self: Ray, t: f32) Vec3 {
        const vect = Vec3{ t, t, t };
        return self.origin + vect * self.direction;
    }

    pub inline fn lengthSquared(self: Ray) f32 {
        return dot(self.direction, self.direction);
    }

    pub inline fn rayColor(self: Ray, world: *Hittable) Vec3 {
        var rec = HitRecord.init(self.origin, self.direction, 0, false);
        var interval = Interval.init(0, math.floatMax(f32));
        if (world.hit(&self, &interval, &rec)) {
            const temp = @as(Vec3, @splat(0.5)) * (rec.normal + @as(Vec3, @splat(1)));
            return temp;
        }
        const unitDirection = normalize(self.direction);
        const a = @as(Vec3, @splat(0.5)) * (@as(Vec3, @splat(unitDirection[1] + 1)));
        const b = (@as(Vec3, @splat(1)) - a) * @as(Vec3, @splat(1)) + a * Vec3{ 0.5, 0.7, 1.0 };
        return b;
    }
};
