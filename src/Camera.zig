const std = @import("std");
const math = std.math;
const normalize = @import("utils.zig").normalize;
const Vec3 = @import("utils.zig").Vec3;
const Ray = @import("Ray.zig").Ray;
const Hittable = @import("Hittable.zig").Hittable;
const Color = @import("Color.zig").Color;
const HitRecord = @import("Hittable.zig").HitRecord;
const Interval = @import("utils.zig").Interval;
const Random = std.Random;

pub const Camera = struct {
    imageWidth: u32,
    imageHeight: u32,
    cameraCenter: Vec3,
    viewportU: Vec3,
    viewportV: Vec3,
    pixelDeltaU: Vec3,
    pixelDeltaV: Vec3,
    viewportUpperLeft: Vec3,
    pixel00Loc: Vec3,
    rand: Random,

    const samplePerPixel = 100;
    const maxDepth: u8 = 50;

    pub fn init(imageWidthU: u32, comptime imageHeightU: u32, comptime viewportWidth: f64, viewportHeight: f64, cameraCenter: Vec3, focalLength: f32, rand: Random) !Camera {
        const imageWidth = @as(f64, @floatFromInt(imageWidthU));
        const imageHeight = @as(f64, @floatFromInt(imageHeightU));
        const vu = Vec3{ viewportWidth, 0, 0 };
        const vh = Vec3{ 0, -viewportHeight, 0 };

        const vu_half = Vec3{ viewportWidth / 2, 0, 0 };
        const vh_half = Vec3{ 0, -viewportHeight / 2, 0 };

        const pdu = Vec3{ viewportWidth / imageWidth, 0, 0 };
        const pdv = Vec3{ 0, -viewportHeight / imageHeight, 0 };

        const vul = cameraCenter - @Vector(3, f64){ 0, 0, focalLength } - vu_half - vh_half;
        const p0l = vul + @Vector(3, f64){ 0.5, 0.5, 0.5 } * (pdu + pdv);

        return Camera{
            .imageWidth = imageWidthU,
            .imageHeight = imageHeightU,
            .cameraCenter = cameraCenter,
            .viewportU = vu,
            .viewportV = vh,
            .pixelDeltaU = pdu,
            .pixelDeltaV = pdv,
            .viewportUpperLeft = vul,
            .pixel00Loc = p0l,
            .rand = rand,
        };
    }

    pub inline fn getRay(self: Camera, i: f64, j: f64) Ray {
        const offset = self.sampleSquare();
        const offsetX = @as(Vec3, @splat(i + offset[0])) * self.pixelDeltaU;
        const offsetY = @as(Vec3, @splat(j + offset[1])) * self.pixelDeltaV;
        const pixelSample = self.pixel00Loc + offsetX + offsetY;
        const rayDir = pixelSample - self.cameraCenter;
        return Ray.init(self.cameraCenter, rayDir);
    }

    pub inline fn sampleSquare(self: Camera) Vec3 {
        const u = self.rand.float(f64);
        const v = self.rand.float(f64);
        return Vec3{ u - 0.5, v - 0.5, 0 };
    }

    pub inline fn render(
        self: Camera,
        comptime imageHeight: usize,
        comptime imageWidth: usize,
        world: *Hittable,
        textureBuffer: *[imageHeight][imageWidth]@Vector(3, u8),
    ) !void {
        for (0..self.imageHeight) |j| {
            var rowBuffer = textureBuffer[j];
            const j_f = @as(f64, @floatFromInt(j));
            for (0..self.imageWidth) |i| {
                var pixelColor = Vec3{ 0, 0, 0 };

                for (0..samplePerPixel) |_| {
                    const i_f = @as(f64, @floatFromInt(i));
                    const ray = self.getRay(i_f, j_f);
                    pixelColor += ray.rayColor(self.rand, world, maxDepth);
                }

                pixelColor /= @as(Vec3, @splat(samplePerPixel));
                const colRes = Color.init(pixelColor[0], pixelColor[1], pixelColor[2]);
                rowBuffer[i] = colRes.color;
            }
            textureBuffer[j] = rowBuffer;
        }
    }
};
