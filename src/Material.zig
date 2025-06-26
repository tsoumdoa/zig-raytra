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
        Dielectric: Dielectric,
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

    pub inline fn scatter(
        self: Lambertian,
        rec: *HitRecord,
        attenuation: *Vec3,
        scattered: *Ray,
        random: Random,
    ) bool {
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

    pub inline fn scatter(self: Metal, rIn: *const Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray, random: Random) bool {
        const reflected = reflect(rIn.direction, rec.normal);
        const unitizedReflected = normalize(reflected) + (@as(Vec3, @splat(self.fuzz))) * randomUnitVector(random);
        scattered.* = Ray.init(rec.p, unitizedReflected);
        attenuation.* = Vec3{ self.r, self.g, self.b };
        return true;
    }
};

pub const Dielectric = struct {
    refractionIndex: f64,

    pub fn init(ir: f64) Dielectric {
        return Dielectric{
            .refractionIndex = ir,
        };
    }

    pub inline fn scatter(self: Dielectric, rIn: *const Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray, random: Random) bool {
        attenuation.* = Vec3{ 1.0, 1.0, 1.0 };
        const ri = self.riValue(rec);
        const unitDir = normalize(rIn.direction);
        const cosTheta = @min(dot(-unitDir, rec.normal), 1.0);
        const sinTheta = @sqrt(1 - cosTheta * cosTheta);

        const cannotRefract = ri * sinTheta > 1.0;
        var dir: Vec3 = undefined;
        if (cannotRefract or reflectance(cosTheta, ri) > random.float(f64)) {
            dir = reflect(unitDir, rec.normal);
        } else {
            dir = refract(unitDir, rec.normal, ri);
        }

        scattered.* = Ray.init(rec.p, dir);
        return true;
    }

    pub inline fn riValue(self: Dielectric, rec: *HitRecord) f64 {
        if (rec.fontFace) {
            return 1.0 / self.refractionIndex;
        } else {
            return self.refractionIndex;
        }
    }
};

pub inline fn reflect(v: Vec3, n: Vec3) Vec3 {
    return v - (@as(Vec3, @splat(2 * dot(v, n))) * n);
}

pub inline fn refract(uv: Vec3, n: Vec3, etaiOverEtat: f64) Vec3 {
    const cosTheta = @min(dot(-uv, n), 1.0);
    const rOutPerp: Vec3 = @as(Vec3, @splat(etaiOverEtat)) * (uv + @as(Vec3, @splat(cosTheta)) * n);
    const rOutParallell = @as(Vec3, @splat(-@sqrt(@abs(1 - dot(rOutPerp, rOutPerp))))) * n;
    return rOutPerp + rOutParallell;
}

pub inline fn reflectance(cosine: f64, rfi: f64) f64 {
    var r0 = (1 - rfi) / (1 + rfi);
    r0 = r0 * r0;
    return r0 + (1 - r0) * std.math.pow(f64, (1 - cosine), 5);
}
