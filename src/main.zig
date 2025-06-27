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
const Dielectric = @import("Material.zig").Dielectric;
const Metal = @import("Material.zig").Metal;
const dot = @import("utils.zig").dot;

const ASPECT_RATIO: f64 = 16.0 / 9.0;
const IMAGE_WIDTH: u32 = 1200; // 400 for dev
const IMAGE_WIDTH_F = @as(f64, @floatFromInt(IMAGE_WIDTH));
const IMAGE_HEIGHT_F = IMAGE_WIDTH_F / ASPECT_RATIO;
const IMAGE_HEIGHT: u32 = @as(u32, @intFromFloat(IMAGE_HEIGHT_F));

const VFOV = 20;
const LOOK_FROM = Vec3{ 13, 2, 3 };
const LOOK_AT = Vec3{ 0, 0, 0 };
const VUP = Vec3{ 0, 1, 0 };

const DEFOCUS_ANGLE: f64 = 0.6;
const FOCUS_DIST: f64 = 10.0;

const FOCAL_LENGTH: f64 = math.sqrt(dot(LOOK_FROM - LOOK_AT, LOOK_FROM - LOOK_AT));
const theta = math.degreesToRadians(VFOV);
const h = math.tan(theta / 2.0);
const VIEWPORT_HEIGHT: f64 = 2 * h * FOCUS_DIST;
const VIEWPORT_WIDTH: f64 = VIEWPORT_HEIGHT * ASPECT_RATIO;
const CAMERA_CENTER: Vec3 = LOOK_FROM;

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

    var a: f64 = -11;

    const groundMat = Material{ .material = .{ .Lambertian = Lambertian.init(Vec3{ 0.5, 0.5, 0.5 }) } };
    try world.add(HittableObject{
        .object = .{
            .sphere = Sphere.init(
                Vec3{ 0, -1000, 0 },
                1000,
                groundMat,
            ),
        },
    });

    while (a < 11) : (a += 1) {
        var b: f64 = -11;
        while (b < 11) : (b += 1) {
            const chooseMat = rand.float(f64);
            const center = Vec3{ a + 0.9 * rand.float(f64), 0.2, b + 0.9 * rand.float(f64) };

            const pt = Vec3{ 4, 0.2, 0 };
            const ptFromCen = center - pt;
            const length = @sqrt(dot(ptFromCen, ptFromCen));

            if (length > 0.9) {
                var sphereMat: Material = undefined;

                if (chooseMat < 0.8) {
                    // diffusae
                    const albedo = Vec3{ rand.float(f64), rand.float(f64), rand.float(f64) };
                    sphereMat = Material{ .material = .{ .Lambertian = Lambertian.init(albedo) } };
                    try world.add(HittableObject{
                        .object = .{
                            .sphere = Sphere.init(
                                center,
                                0.2,
                                sphereMat,
                            ),
                        },
                    });
                } else if (chooseMat < 0.95) {
                    // metal
                    const albedo = Vec3{
                        (rand.float(f64) + 1) / 2,
                        (rand.float(f64) + 1) / 2,
                        (rand.float(f64) + 1) / 2,
                    };
                    const fuzz = (rand.float(f64) + 1) / 2;
                    sphereMat = Material{ .material = .{ .Metal = Metal.init(albedo, fuzz) } };
                    try world.add(HittableObject{
                        .object = .{
                            .sphere = Sphere.init(
                                center,
                                0.2,
                                sphereMat,
                            ),
                        },
                    });
                } else {
                    // glass
                    sphereMat = Material{ .material = .{ .Dielectric = Dielectric.init(1.5) } };
                    try world.add(HittableObject{
                        .object = .{
                            .sphere = Sphere.init(
                                center,
                                0.2,
                                sphereMat,
                            ),
                        },
                    });
                }
            }
        }
    }

    const materialOne = Material{ .material = .{ .Dielectric = Dielectric.init(1.5) } };
    const materialTwo = Material{ .material = .{ .Lambertian = Lambertian.init(Vec3{ 0.4, 0.2, 0.1 }) } };
    const materialThree = Material{ .material = .{ .Metal = Metal.init(Vec3{ 0.7, 0.6, 0.5 }, 0.0) } };

    try world.add(HittableObject{
        .object = .{
            .sphere = Sphere.init(
                Vec3{ 0, 1, 0 },
                1.0,
                materialOne,
            ),
        },
    });
    try world.add(HittableObject{
        .object = .{
            .sphere = Sphere.init(
                Vec3{ -4, 1, 0 },
                1.0,
                materialTwo,
            ),
        },
    });
    try world.add(HittableObject{
        .object = .{
            .sphere = Sphere.init(
                Vec3{ 4, 1, 0 },
                1.0,
                materialThree,
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
        VFOV,
        rand,
        LOOK_FROM,
        LOOK_AT,
        VUP,
        DEFOCUS_ANGLE,
        FOCUS_DIST,
    );
    try camera.render(IMAGE_HEIGHT, IMAGE_WIDTH, &world, &textureBuffer);
    try writeToFile("texture.ppm", IMAGE_WIDTH, IMAGE_HEIGHT, &textureBuffer);
}

test {
    testing.refAllDecls(utils);
}
