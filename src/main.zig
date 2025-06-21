const std = @import("std");
const format = std.fmt.format;
const stdout = std.io.getStdOut().writer();
const ArrayList = std.ArrayList;
const print = std.debug.print;
const writeToFile = @import("utils.zig").writeToFile;
const testing = std.testing;
const utils = @import("utils.zig");
const Color = @import("Color.zig").Color;
const Vec3 = @import("utils.zig").Vec3;
const Camera = @import("Camera.zig").Camera;
const Ray = @import("Ray.zig").Ray;

const ASPECT_RATIO: f32 = 16.0 / 9.0;
const IMAGE_WIDTH: u32 = 256;
const IMAGE_WIDTH_F = @as(f32, @floatFromInt(IMAGE_WIDTH));
const IMAGE_HEIGHT_F = IMAGE_WIDTH_F / ASPECT_RATIO;
const IMAGE_HEIGHT: u32 = @as(u32, @intFromFloat(IMAGE_HEIGHT_F));

const FOCAL_LENGTH: f32 = 1.0;
const VIEWPORT_HEIGHT: f32 = 2.0;
const VIEWPORT_WIDTH: f32 = VIEWPORT_HEIGHT * ASPECT_RATIO;
const CAMERA_CENTER: Vec3 = @Vector(3, f32){ 0, 0, 0 };

pub fn main() !void {
    var texture_buffer: [IMAGE_HEIGHT][IMAGE_WIDTH]@Vector(3, u8) = @splat(@splat(@Vector(3, u8){ 0, 4, 0 }));

    const camera = Camera.init(IMAGE_WIDTH_F, IMAGE_HEIGHT_F, VIEWPORT_WIDTH, VIEWPORT_HEIGHT, CAMERA_CENTER, FOCAL_LENGTH);

    for (0..IMAGE_HEIGHT) |j| {
        var row_buffer = texture_buffer[j];
        const j_f = @as(f32, @floatFromInt(j));
        for (0..IMAGE_WIDTH) |i| {
            const i_f = @as(f32, @floatFromInt(i));

            const pixelCenter = camera.getPixel(i_f, j_f);
            const rayDir = pixelCenter - CAMERA_CENTER;

            const ray = Ray.init(CAMERA_CENTER, rayDir);

            const c = ray.rayColor();

            row_buffer[i] = c.color;
        }
        texture_buffer[j] = row_buffer;
    }

    try writeToFile("texture.ppm", IMAGE_WIDTH, IMAGE_HEIGHT, &texture_buffer);
}

test {
    testing.refAllDecls(utils);
}
