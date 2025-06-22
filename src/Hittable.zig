const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Vec3 = @import("utils.zig").Vec3;
const Ray = @import("Ray.zig").Ray;
const dot = @import("utils.zig").dot;

pub const HitRecord = struct {
    p: Vec3,
    normal: Vec3,
    t: f32,
};

pub const HittableObject = struct {
    objectType: ObjectType,
    object: union {
        sphere: Sphere,
        plane: Plane,
    },
};

pub const ObjectType = enum {
    SPHERE,
    PLANE,
};

pub const Hittable = struct {
    hittableObject: ArrayList(HittableObject),

    pub fn init(allocator: Allocator) Hittable {
        const hittableObject = ArrayList(HittableObject).init(allocator);
        return Hittable{
            .hittableObject = hittableObject,
        };
    }

    pub fn add(self: *Hittable, hittableObject: HittableObject) !void {
        try self.hittableObject.append(hittableObject);
    }
};

pub const Sphere = struct {
    center: Vec3,
    radius: f32,

    pub fn init(center: Vec3, radius: f32) Sphere {
        return Sphere{
            .center = center,
            .radius = radius,
        };
    }

    pub fn hit(self: Sphere, ray: Ray, t_min: f32, t_max: f32) f32 {
        const oc = self.center - ray.origin;
        const a = dot(ray.direction, ray.direction);
        const b = dot(oc, ray.direction);
        const c = dot(oc, oc) - self.radius * self.radius;
        const discriminant = b * b - a * c;

        if (discriminant > 0) {
            const temp = (-b - math.sqrt(discriminant)) / a;
            if (temp < t_max and temp > t_min) {
                return temp;
            }
        }
        return -1;
    }
};

pub const Plane = struct {
    normal: Vec3,
    offset: f32,

    pub fn init(normal: Vec3, offset: f32) Plane {
        return Plane{
            .normal = normal,
            .offset = offset,
        };
    }

    pub fn hit(self: Plane, ray: Ray, t_min: f32, t_max: f32) f32 {
        _ = t_max;
        const denom = dot(ray.direction, self.normal);
        if (denom > 0) {
            return -1;
        }

        const t = (self.offset - dot(self.normal, ray.origin)) / denom;
        if (t < t_min) {
            return -1;
        }

        return t;
    }
};
