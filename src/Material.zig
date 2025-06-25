const Vec3 = @import("utils.zig").Vec3;
const Color = @import("Color.zig").Color;

pub const Material = struct {
    object: union(enum) {
        Lambertian: Lambertian,
        Steel: Steel,
    },
};

pub const Lambertian = struct {
    color: Color,

    pub fn init(c: Vec3) Lambertian {
        return Lambertian{
            .albedo = Color.init(c[0], c[1], c[2]),
        };
    }
};

pub const Steel = struct {
    color: Color,
    specular: Vec3,

    pub fn init(albedo: Vec3, specular: Vec3) Steel {
        return Steel{
            .albedo = albedo,
            .specular = specular,
        };
    }
};
