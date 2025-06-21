const Vec3 = @import("utils.zig").Vec3;
const Color = @import("Color.zig").Color;
const normalize = @import("utils.zig").normalize;

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
        const unitDir = normalize(self.direction);
        const a = 0.5 * (unitDir[1] + 1);

        const d = 1.0 - a;
        const a0 = @Vector(3, f32){ d, d, d };
        const a1 = @Vector(3, f32){ 0.5 * a, 0.7 * a, 1 * a };

        const t = a0 + a1;

        return Color.init(t[0], t[1], t[2]);
    }
};
