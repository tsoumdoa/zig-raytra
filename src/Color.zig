pub const Color = struct {
    color: [3]u8,

    pub inline fn init(r: f32, g: f32, b: f32) Color {
        const rc = @as(u8, @intFromFloat(r * 255.999));
        const gc = @as(u8, @intFromFloat(g * 255.999));
        const bc = @as(u8, @intFromFloat(b * 255.999));
        return Color{ .color = [3]u8{ rc, gc, bc } };
    }
};
