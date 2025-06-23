const std = @import("std");
const math = std.math;
const normalize = @import("utils.zig").normalize;
const Vec3 = @import("utils.zig").Vec3;
const Ray = @import("Ray.zig").Ray;
const Hittable = @import("Hittable.zig").Hittable;
const Color = @import("Color.zig").Color;
const HitRecord = @import("Hittable.zig").HitRecord;
const Interval = @import("utils.zig").Interval;

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

    const samplePerPixel = 10;

    pub fn init(imageWidthU: u32, comptime imageHeightU: u32, comptime viewportWidth: f32, viewportHeight: f32, cameraCenter: Vec3, focalLength: f32) Camera {
        const imageWidth = @as(f32, @floatFromInt(imageWidthU));
        const imageHeight = @as(f32, @floatFromInt(imageHeightU));
        const vu = Vec3{ viewportWidth, 0, 0 };
        const vh = Vec3{ 0, -viewportHeight, 0 };

        const vu_half = Vec3{ viewportWidth / 2, 0, 0 };
        const vh_half = Vec3{ 0, -viewportHeight / 2, 0 };

        const pdu = Vec3{ viewportWidth / imageWidth, 0, 0 };
        const pdv = Vec3{ 0, -viewportHeight / imageHeight, 0 };

        const vul = cameraCenter - @Vector(3, f32){ 0, 0, focalLength } - vu_half - vh_half;
        const p0l = vul + @Vector(3, f32){ 0.5, 0.5, 0.5 } * (pdu + pdv);

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
        };
    }

    pub inline fn getPixel(self: Camera, u: f32, v: f32) Vec3 {
        const vecU = @Vector(3, f32){ u, u, u };
        const vecV = @Vector(3, f32){ v, v, v };
        return self.pixel00Loc + self.pixelDeltaU * vecU + self.pixelDeltaV * vecV;
    }

    // TODO: get_ray
    pub inline fn getRay(self: Camera, u: f32, v: f32) Ray {
        const pixelCenter = self.getPixel(u, v);
        const rayDir = pixelCenter - self.cameraCenter;
        return Ray.init(self.cameraCenter, rayDir);
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
            const j_f = @as(f32, @floatFromInt(j));
            for (0..self.imageWidth) |i| {
                const i_f = @as(f32, @floatFromInt(i));

                const pixelCenter = self.getPixel(i_f, j_f);
                const rayDir = pixelCenter - self.cameraCenter;
                const ray = Ray.init(self.cameraCenter, rayDir);

                const c = ray.rayColor(world);

                rowBuffer[i] = c.color;
            }
            textureBuffer[j] = rowBuffer;
        }
    }
};
