const Error = @import("errors.zig").Error;
const mem = @import("std").mem;

pub const Image = struct {
    data: []const u8,
    width: usize,
    height: usize,

    pub fn new(allocator: mem.Allocator, data: []const u8, width: usize, height: usize) !*Image {
        if (data.len < (width * height * 4)) {
            return Error.ValueOutOfRange;
        }

        const image = try allocator.create(Image);
        image.* = Image{
            .data = data,
            .width = width,
            .height = height,
        };
        return image;
    }

    pub fn destroy(self: *Image, allocator: mem.Allocator) void {
        allocator.destroy(self);
    }
};
