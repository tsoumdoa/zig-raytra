const std = @import("std");
const Random = std.Random;
const dot = @import("utils.zig").dot;
const Vec3 = @import("utils.zig").Vec3;
const Color = @import("Color.zig").Color;
const HitRecord = @import("Hittable.zig").HitRecord;
const Ray = @import("Ray.zig").Ray;
const randomUnitVector = @import("utils.zig").randomUnitVector;
const normalize = @import("utils.zig").normalize;

pub const Material = struct {
    material: union(enum) {
        Lambertian: Lambertian,
        Metal: Metal,
    },
};

pub const Lambertian = struct {
    albedo: Color,
    r: f64,
    g: f64,
    b: f64,

    pub fn init(c: Vec3) Lambertian {
        return Lambertian{
            .albedo = Color.init(c[0], c[1], c[2]),
            .r = c[0],
            .g = c[1],
            .b = c[2],
        };
    }

    pub inline fn scatter(self: Lambertian, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray, random: Random) bool {
        var scatterDir = rec.normal + randomUnitVector(random);
        const scatterRay = Ray.init(rec.normal, scatterDir);
        if (scatterRay.nearZero()) {
            scatterDir = rec.normal;
        }

        scattered.* = Ray.init(rec.p, scatterDir);
        attenuation.* = Vec3{ self.r, self.g, self.b };
        return true;
    }
};

pub const Metal = struct {
    albedo: Color,
    fuzz: f64,
    r: f64,
    g: f64,
    b: f64,

    pub fn init(c: Vec3, fuzz: f64) Metal {
        return Metal{
            .albedo = Color.init(c[0], c[1], c[2]),
            .fuzz = fuzz,
            .r = c[0],
            .g = c[1],
            .b = c[2],
        };
    }

    pub inline fn reflect(self: Metal, v: Vec3, n: Vec3) Vec3 {
        _ = self;
        return v - (@as(Vec3, @splat(2 * dot(v, n))) * n);
    }

    pub inline fn scatter(self: Metal, rIn: *const Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray, random: Random) bool {
        const reflected = self.reflect(rIn.direction, rec.normal);
        const unitizedReflected = normalize(reflected) + (@as(Vec3, @splat(self.fuzz))) * randomUnitVector(random);
        scattered.* = Ray.init(rec.p, unitizedReflected);
        attenuation.* = Vec3{ self.r, self.g, self.b };
        return true;
    }
};
