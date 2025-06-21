const std = @import("std");
const format = std.fmt.format;
const stdout = std.io.getStdOut().writer();
const ArrayList = std.ArrayList;
const print = std.debug.print;
const writeToFile = @import("utils.zig").writeToFile;

pub fn main() !void {
    const image_width: u32 = 256;
    const image_height: u32 = 256;
    const ih_f = @as(f32, @floatFromInt(image_height));
    const iw_f = @as(f32, @floatFromInt(image_width));
    var texture_buffer: [image_height][image_width]@Vector(3, u8) = @splat(@splat(@Vector(3, u8){ 0, 4, 0 }));

    for (0..image_height) |j| {
        var row_buffer = texture_buffer[j];
        const j_f = @as(f32, @floatFromInt(j));
        const g = @as(u8, @intFromFloat((j_f / (ih_f - 1) * 255.999)));
        const b = @as(u8, @intCast(0));
        for (0..image_width) |i| {
            const i_f = @as(f32, @floatFromInt(i));
            const r = @as(u8, @intFromFloat((i_f / (iw_f - 1) * 255.999)));
            row_buffer[i] = @Vector(3, u8){ r, g, b };
        }
        texture_buffer[j] = row_buffer;
    }

    try writeToFile("texture.ppm", image_width, image_height, &texture_buffer);
}
