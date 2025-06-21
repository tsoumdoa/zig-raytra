const std = @import("std");
const format = std.fmt.format;
const stdout = std.io.getStdOut().writer();

pub inline fn writeToFile(file_name: []const u8, image_width: u32, image_height: u32, texture_buffer: *[image_width][image_height]@Vector(3, u8)) !void {
    const ppm = try std.fs.cwd().createFile(file_name, .{});
    defer ppm.close();
    try format(ppm.writer(), "P3\n {d} {d}\n255\n", .{ image_width, image_height });
    for (0..image_height) |j| {
        try stdout.print("\x1BM \x1b[1;37m Scanlines remaining: {d}\n", .{image_height - j});
        const row = texture_buffer[j];
        for (0..image_width) |i| {
            const pixel = row[i];
            try std.fmt.format(ppm.writer(), "{d} {d} {d}\n", .{ pixel[0], pixel[1], pixel[2] });
        }
    }
}
