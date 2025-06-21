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

    pub inline fn rayColor(self: Ray) Color {
        if (self.hitSphere(Vec3{ 0, 0, -1 }, 0.5)) {
            return Color.init(1, 0, 0);
        }

        const unitDir = normalize(self.direction);
        const a = 0.5 * (unitDir[1] + 1);

        const d = 1.0 - a;
        const a0 = @Vector(3, f32){ d, d, d };
        const a1 = @Vector(3, f32){ 0.5 * a, 0.7 * a, 1 * a };

        const t = a0 + a1;

        return Color.init(t[0], t[1], t[2]);
    }

    pub inline fn hitSphere(self: Ray, center: Vec3, radius: f32) bool {
        const oc = self.origin - center;
        const a = dot(self.direction, self.direction);
        const b = dot(oc, self.direction);
        const c = dot(oc, oc) - radius * radius;
        const discriminant = b * b - a * c;
        return discriminant >= 0;
    }
};
