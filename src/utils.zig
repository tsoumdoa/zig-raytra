const std = @import("std");
const format = std.fmt.format;
const stdout = std.io.getStdOut().writer();

pub const Vec3 = @Vector(3, f32);

pub const Interval = struct {
    min: f32,
    max: f32,

    pub fn init(min: f32, max: f32) Interval {
        return Interval{
            .min = min,
            .max = max,
        };
    }

    pub inline fn size(self: Interval) f32 {
        return self.max - self.min;
    }

    pub inline fn contains(self: Interval, x: f32) bool {
        return self.min <= x and x <= self.max;
    }

    pub inline fn surrounds(self: Interval, x: f32) bool {
        return self.min < x and x < self.max;
    }
};

pub inline fn writeToFile(file_name: []const u8, image_width: u32, image_height: u32, texture_buffer: *[image_height][image_width]@Vector(3, u8)) !void {
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

pub inline fn dot(a: @Vector(3, f32), b: @Vector(3, f32)) f32 {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

pub inline fn cross(a: @Vector(3, f32), b: @Vector(3, f32)) @Vector(3, f32) {
    return @Vector(3, f32){
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    };
}

pub inline fn normalize(v: @Vector(3, f32)) @Vector(3, f32) {
    const len = std.math.sqrt(dot(v, v));
    return v / @Vector(3, f32){ len, len, len };
}

test "dot" {
    const a = @Vector(3, f32){ 1, 2, 3 };
    const b = @Vector(3, f32){ 4, 5, 6 };
    const c = dot(a, b);
    try std.testing.expectEqual(c, 32);
}

test "cross" {
    const a = @Vector(3, f32){ 1, 2, 3 };
    const b = @Vector(3, f32){ 4, 5, 6 };
    const c = cross(a, b);
    try std.testing.expectEqual(c[0], -3);
    try std.testing.expectEqual(c[1], 6);
    try std.testing.expectEqual(c[2], -3);
}

test "normalize" {
    const a = @Vector(3, f32){ 1, 1, 1 };
    const b = normalize(a);
    try std.testing.expectEqual(b[0], 0.57735026);
    try std.testing.expectEqual(b[1], 0.57735026);
    try std.testing.expectEqual(b[2], 0.57735026);
}
