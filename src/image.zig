const Error = @import("errors.zig").Error;
const allocator = @import("std").heap.c_allocator;

pub const Image = struct {
    data: []const u8,
    width: usize,
    height: usize,

    pub fn new(data: []const u8, width: usize, height: usize) !*Image {
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

    pub fn destroy(self: *Image) void {
        allocator.destroy(self);
    }
};
