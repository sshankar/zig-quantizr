const Image = @import("image.zig").Image;
const Histogram = @import("histogram.zig").Histogram;

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

export fn quantizr_create_histogram() ?*Histogram {
    return Histogram.new() catch return null;
}

export fn quantizr_histogram_add_image(hist: *Histogram, image: *Image) void {
    hist.add_image(image) catch return;
}

export fn quantizr_free_histogram(histogram: *Histogram) void {
    histogram.destroy();
}
