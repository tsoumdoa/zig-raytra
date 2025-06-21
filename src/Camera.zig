const Vec3 = @import("utils.zig").Vec3;

pub const Camera = struct {
    viewportU: Vec3,
    viewportV: Vec3,
    pixelDeltaU: Vec3,
    pixelDeltaV: Vec3,
    viewportUpperLeft: Vec3,
    pixel00Loc: Vec3,

    pub fn init(imageWidth: f32, imageHeight: f32, viewportWidth: f32, viewportHeight: f32, cameraCenter: Vec3, focalLength: f32) Camera {
        const vu = Vec3{ viewportWidth, 0, 0 };
        const vh = Vec3{ 0, -viewportHeight, 0 };

        const vu_half = Vec3{ viewportWidth / 2, 0, 0 };
        const vh_half = Vec3{ 0, -viewportHeight / 2, 0 };

        const pdu = Vec3{ viewportWidth / imageWidth, 0, 0 };
        const pdv = Vec3{ 0, -viewportHeight / imageHeight, 0 };

        const vul = cameraCenter - @Vector(3, f32){ 0, 0, focalLength } - vu_half - vh_half;
        const p0l = vul + @Vector(3, f32){ 0.5, 0.5, 0.5 } * (pdu + pdv);

        return Camera{
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
};
