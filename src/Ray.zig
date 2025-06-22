const Vec3 = @import("utils.zig").Vec3;
const Color = @import("Color.zig").Color;
const normalize = @import("utils.zig").normalize;
const dot = @import("utils.zig").dot;
const std = @import("std");
const math = std.math;

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

    pub inline fn rayColor(self: Ray) Color {
        const sp = self.hitSphere(Vec3{ 0, 0, -1 }, 0.5);
        if (sp > 0) {
            const norm = normalize(self.at(sp) - Vec3{ 0, 0, -1 });
            const cv = norm + @as(Vec3, @splat(1));
            const cv_half = cv * @as(Vec3, @splat(0.5));
            const c = Color.init(cv_half[0], cv_half[1], cv_half[2]);
            return c;
        }

        const unitDir = normalize(self.direction);
        const a = 0.5 * (unitDir[1] + 1);

        const d = 1.0 - a;
        const a0 = @as(@Vector(3, f32), @splat(d));
        const a1 = @Vector(3, f32){ 0.5 * a, 0.7 * a, 1 * a };

        const t = a0 + a1;

        return Color.init(t[0], t[1], t[2]);
    }

    pub inline fn hitSphere(self: Ray, center: Vec3, radius: f32) f32 {
        const oc = center - self.origin;
        const a = self.lengthSquared();
        const h = dot(self.direction, oc);
        const c = self.lengthSquared() - radius * radius;
        const discriminant = h * h - a * c;

        if (discriminant < 0) {
            return -1;
        } else {
            return (h - math.sqrt(discriminant)) / a;
        }
    }
};
