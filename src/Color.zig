const Interval = @import("utils.zig").Interval;
const intensity = Interval.init(0, 0.999);

pub const Color = struct {
    color: @Vector(3, u8),

    pub fn init(r: f32, g: f32, b: f32) Color {
        const rc = @as(u8, @intFromFloat(intensity.clamp(r) * 256));
        const gc = @as(u8, @intFromFloat(intensity.clamp(g) * 256));
        const bc = @as(u8, @intFromFloat(intensity.clamp(b) * 256));
        return Color{ .color = @Vector(3, u8){ rc, gc, bc } };
    }
};
