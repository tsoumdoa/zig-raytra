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
const cross = @import("utils.zig").cross;
const randomInUnitDisk = @import("utils.zig").randomInUnitDisk;

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
    vfov: f64,
    rand: Random,
    lookFrom: Vec3,
    lookAt: Vec3,
    vup: Vec3,
    defocusDiskU: Vec3,
    defocusDiskV: Vec3,
    defocusAngle: f64,

    const samplePerPixel = 200; //10 for dev
    const maxDepth: u8 = 50;

    pub fn init(
        imageWidthU: u32,
        comptime imageHeightU: u32,
        comptime viewportWidth: f64,
        viewportHeight: f64,
        cameraCenter: Vec3,
        vfov: f64,
        rand: Random,
        lookFrom: Vec3,
        lookAt: Vec3,
        vup: Vec3,
        DEFOCUS_ANGLE: f64,
        FOCUS_DIST: f64,
    ) !Camera {
        const imageWidth = @as(f64, @floatFromInt(imageWidthU));
        const imageHeight = @as(f64, @floatFromInt(imageHeightU));

        const w = normalize(lookFrom - lookAt);
        const u = normalize(cross(vup, w));
        const v = cross(w, u);

        const vu = @as(Vec3, @splat(viewportWidth)) * u;
        const vh = @as(Vec3, @splat(viewportHeight)) * -v;

        const vu_half = vu / @as(Vec3, @splat(2));
        const vh_half = vh / @as(Vec3, @splat(2));

        const pdu = vu / @as(Vec3, @splat(imageWidth));
        const pdv = vh / @as(Vec3, @splat(imageHeight));

        const vul = cameraCenter - (@as(Vec3, @splat(FOCUS_DIST)) * w) - vu_half - vh_half;
        const p0l = vul + @Vector(3, f64){ 0.5, 0.5, 0.5 } * (pdu + pdv);

        const defocutRadius = FOCUS_DIST * math.tan(math.degreesToRadians(DEFOCUS_ANGLE / 2));

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
            .vfov = vfov,
            .rand = rand,
            .lookFrom = lookFrom,
            .lookAt = lookAt,
            .vup = vup,
            .defocusDiskU = @as(Vec3, @splat(defocutRadius)) * u,
            .defocusDiskV = @as(Vec3, @splat(defocutRadius)) * v,
            .defocusAngle = DEFOCUS_ANGLE,
        };
    }

    pub inline fn getRay(self: Camera, i: f64, j: f64) Ray {
        const offset = self.sampleSquare();
        const offsetX = @as(Vec3, @splat(i + offset[0])) * self.pixelDeltaU;
        const offsetY = @as(Vec3, @splat(j + offset[1])) * self.pixelDeltaV;
        const pixelSample = self.pixel00Loc + offsetX + offsetY;

        const rayOri = self.rayOrigin();
        const rayDir = pixelSample - rayOri;
        return Ray.init(rayOri, rayDir);
    }

    pub inline fn rayOrigin(self: Camera) Vec3 {
        if (self.defocusAngle <= 0) {
            return self.cameraCenter;
        } else {
            return self.defocusDiskSample();
        }
    }

    pub inline fn defocusDiskSample(self: Camera) Vec3 {
        const p = randomInUnitDisk(self.rand);
        return self.cameraCenter + (@as(Vec3, @splat(p[0])) * self.defocusDiskU) + (@as(Vec3, @splat(p[1])) * self.defocusDiskV);
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
