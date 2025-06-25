const Interval = @import("utils.zig").Interval;
const intensity = Interval.init(0, 0.999);
const std = @import("std");

pub const Color = struct {
    color: @Vector(3, u8),

    pub fn init(rLinear: f64, gLinear: f64, bLinear: f64) Color {
        const r = linearToGamma(rLinear);
        const g = linearToGamma(gLinear);
        const b = linearToGamma(bLinear);
        const rc = @as(u8, @intFromFloat(intensity.clamp(r) * 256));
        const gc = @as(u8, @intFromFloat(intensity.clamp(g) * 256));
        const bc = @as(u8, @intFromFloat(intensity.clamp(b) * 256));
        return Color{ .color = @Vector(3, u8){ rc, gc, bc } };
    }
};

pub inline fn linearToGamma(linearComponent: f64) f64 {
    if(linearComponent > 0) return std.math.sqrt(linearComponent);
    return 0;
}
