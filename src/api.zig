const Image = @import("image.zig").Image;

export fn quantizr_create_image_rgba(data: [*]const u8, width: i32, height: i32) ?*Image {
    const w: usize = @intCast(width);
    const h: usize = @intCast(height);
    const size = w * h * 4;
    const ds = data[0..size];

    return Image.new(ds, w, h) catch return null;
}

export fn quantizr_free_image(image: *Image) void {
    image.destroy();
}
