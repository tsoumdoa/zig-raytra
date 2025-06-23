const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Vec3 = @import("utils.zig").Vec3;
const Ray = @import("Ray.zig").Ray;
const dot = @import("utils.zig").dot;
const object = @import("Object.zig");
const Interval = @import("utils.zig").Interval;

pub const HitRecord = struct {
    p: Vec3,
    normal: Vec3,
    t: f32,
    fontFace: bool,

    pub inline fn init(p: Vec3, normal: Vec3, t: f32, fontFace: bool) HitRecord {
        return HitRecord{
            .p = p,
            .normal = normal,
            .t = t,
            .fontFace = fontFace,
        };
    }

    pub inline fn setFaceNormal(self: *HitRecord, r: *const Ray, outwardNrml: Vec3) void {
        const frontFace = dot(r.direction, outwardNrml);
        if (frontFace > 0) {
            self.normal = -outwardNrml;
            self.fontFace = false;
        } else {
            self.normal = outwardNrml;
            self.fontFace = true;
        }
    }
};

pub const HittableObject = struct {
    object: union(enum) {
        sphere: object.Sphere,
    },
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

    pub inline fn hit(self: *Hittable, r: *const Ray, rayT: *Interval, hitRec: *HitRecord) bool {
        var tempRec = HitRecord.init(Vec3{ 0, 0, 0 }, Vec3{ 0, 0, 0 }, 0, false);
        var hitAnything = false;
        var closestSoFar = rayT.max;

        for (self.hittableObject.items) |hittableObject| {
            const interval = Interval.init(rayT.min, closestSoFar);
            const hitP = switch (hittableObject.object) {
                .sphere => |sphere| sphere.hit(r, interval, &tempRec),
            };
            if (hitP) {
                hitAnything = true;
                closestSoFar = tempRec.t;
                hitRec.* = tempRec;
            }
        }
        return hitAnything;
    }
};
