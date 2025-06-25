const std = @import("std");
const format = std.fmt.format;
const stdout = std.io.getStdOut().writer();
const math = std.math;
const ArrayList = std.ArrayList;
const print = std.debug.print;
const writeToFile = @import("utils.zig").writeToFile;
const testing = std.testing;
const utils = @import("utils.zig");
const Color = @import("Color.zig").Color;
const Vec3 = @import("utils.zig").Vec3;
const Camera = @import("Camera.zig").Camera;
const Ray = @import("Ray.zig").Ray;
const Hittable = @import("Hittable.zig").Hittable;
const HittableObject = @import("Hittable.zig").HittableObject;
const ObjectType = @import("Hittable.zig").ObjectType;
const Sphere = @import("Object.zig").Sphere;
const Random = std.Random;
const Material = @import("Material.zig").Material;
const Lambertian = @import("Material.zig").Lambertian;
const Steel = @import("Material.zig").Steel;

const ASPECT_RATIO: f64 = 16.0 / 9.0;
const IMAGE_WIDTH: u32 = 400;
const IMAGE_WIDTH_F = @as(f64, @floatFromInt(IMAGE_WIDTH));
const IMAGE_HEIGHT_F = IMAGE_WIDTH_F / ASPECT_RATIO;
const IMAGE_HEIGHT: u32 = @as(u32, @intFromFloat(IMAGE_HEIGHT_F));

const FOCAL_LENGTH: f64 = 1.0;
const VIEWPORT_HEIGHT: f64 = 2.0;
const VIEWPORT_WIDTH: f64 = VIEWPORT_HEIGHT * ASPECT_RATIO;
const CAMERA_CENTER: Vec3 = @Vector(3, f64){ 0, 0, 0 };

pub fn main() !void {
    var gpa_impl: std.heap.GeneralPurposeAllocator(.{}) = .{};
    const gpa = gpa_impl.allocator();
    var arena_impl = std.heap.ArenaAllocator.init(gpa);
    const arena = arena_impl.allocator();
    defer arena_impl.deinit();

    var prng = Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    var world = Hittable.init(arena);

    const middleSphere = Lambertian.init(Vec3{ 0.1, 0.2, 0.5 });
    const groundSphere = Lambertian.init(Vec3{ 0.8, 0.8, 0 });

    try world.add(HittableObject{
        .object = .{
            .sphere = Sphere.init(
                Vec3{ 0, 0, -1 },
                0.5,
                .{ .material = .{ .Lambertian = middleSphere } },
            ),
        },
    });
    try world.add(HittableObject{
        .object = .{
            .sphere = Sphere.init(
                Vec3{ 0, -100.5, -1 },
                100,
                .{ .material = .{ .Lambertian = groundSphere } },
            ),
        },
    });

    var textureBuffer: [IMAGE_HEIGHT][IMAGE_WIDTH]@Vector(3, u8) = @splat(@splat(@Vector(3, u8){ 0, 4, 0 }));

    const camera = try Camera.init(
        IMAGE_WIDTH,
        IMAGE_HEIGHT,
        VIEWPORT_WIDTH,
        VIEWPORT_HEIGHT,
        CAMERA_CENTER,
        FOCAL_LENGTH,
        rand,
    );
    try camera.render(IMAGE_HEIGHT, IMAGE_WIDTH, &world, &textureBuffer);
    try writeToFile("texture.ppm", IMAGE_WIDTH, IMAGE_HEIGHT, &textureBuffer);
}

test {
    testing.refAllDecls(utils);
}
