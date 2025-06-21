const std = @import("std");
const testing = std.testing;
const rand = std.rand;

const Image = @import("image.zig").Image;
const Histogram = @import("histogram.zig").Histogram;
const HistogramEntry = @import("histogram.zig").HistogramEntry;

const image_width: usize = 10;
const image_height: usize = 10;
// For each pixel at (x, y)
// - R = x * 25 (0, 25, ..., 225)
// - G = y * 25 (0, 25, ..., 225)
// - B = (x+y) * 12 (0, 12, 24, ..., 216)
// - A = 255
const image_data: []const u8 = &[_]u8{
    // Row 0
    0, 0,   0,   255, 25, 0,   12,  255, 50, 0,   24,  255, 75, 0,   36,  255, 100, 0,   48,  255, 125, 0,   60,  255, 150, 0,   72,  255, 175, 0,   84,  255, 200, 0,   96,  255, 225, 0,   108, 255,
    // Row 1
    0, 25,  12,  255, 25, 25,  24,  255, 50, 25,  36,  255, 75, 25,  48,  255, 100, 25,  60,  255, 125, 25,  72,  255, 150, 25,  84,  255, 175, 25,  96,  255, 200, 25,  108, 255, 225, 25,  120, 255,
    // Row 2
    0, 50,  24,  255, 25, 50,  36,  255, 50, 50,  48,  255, 75, 50,  60,  255, 100, 50,  72,  255, 125, 50,  84,  255, 150, 50,  96,  255, 175, 50,  108, 255, 200, 50,  120, 255, 225, 50,  132, 255,
    // Row 3
    0, 75,  36,  255, 25, 75,  48,  255, 50, 75,  60,  255, 75, 75,  72,  255, 100, 75,  84,  255, 125, 75,  96,  255, 150, 75,  108, 255, 175, 75,  120, 255, 200, 75,  132, 255, 225, 75,  144, 255,
    // Row 4
    0, 100, 48,  255, 25, 100, 60,  255, 50, 100, 72,  255, 75, 100, 84,  255, 100, 100, 96,  255, 125, 100, 108, 255, 150, 100, 120, 255, 175, 100, 132, 255, 200, 100, 144, 255, 225, 100, 156, 255,
    // Row 5
    0, 125, 60,  255, 25, 125, 72,  255, 50, 125, 84,  255, 75, 125, 96,  255, 100, 125, 108, 255, 125, 125, 120, 255, 150, 125, 132, 255, 175, 125, 144, 255, 200, 125, 156, 255, 225, 125, 168, 255,
    // Row 6
    0, 150, 72,  255, 25, 150, 84,  255, 50, 150, 96,  255, 75, 150, 108, 255, 100, 150, 120, 255, 125, 150, 132, 255, 150, 150, 144, 255, 175, 150, 156, 255, 200, 150, 168, 255, 225, 150, 180, 255,
    // Row 7
    0, 175, 84,  255, 25, 175, 96,  255, 50, 175, 108, 255, 75, 175, 120, 255, 100, 175, 132, 255, 125, 175, 144, 255, 150, 175, 156, 255, 175, 175, 168, 255, 200, 175, 180, 255, 225, 175, 192, 255,
    // Row 8
    0, 200, 96,  255, 25, 200, 108, 255, 50, 200, 120, 255, 75, 200, 132, 255, 100, 200, 144, 255, 125, 200, 156, 255, 150, 200, 168, 255, 175, 200, 180, 255, 200, 200, 192, 255, 225, 200, 204, 255,
    // Row 9
    0, 225, 108, 255, 25, 225, 120, 255, 50, 225, 132, 255, 75, 225, 144, 255, 100, 225, 156, 255, 125, 225, 168, 255, 150, 225, 180, 255, 175, 225, 192, 255, 200, 225, 204, 255, 225, 225, 216, 255,
};

test "simple image histogram" {
    var h: *Histogram = try Histogram.new(testing.allocator);
    defer h.destroy(testing.allocator);

    var i: *Image = try Image.new(testing.allocator, image_data, image_width, image_height);
    defer i.destroy(testing.allocator);

    try h.add_image(i);
    try testing.expectEqual(image_width * image_height, h.map.count());
}

test "transparent image historgram" {
    var dc: [image_height * image_width * 4]u8 = undefined;
    @memcpy(&dc, image_data);

    // set alpha to 0
    var idx: usize = 0;
    while (idx < dc.len) : (idx += 4) {
        dc[idx + 3] = 0;
    }

    var h: *Histogram = try Histogram.new(testing.allocator);
    defer h.destroy(testing.allocator);

    var i: *Image = try Image.new(testing.allocator, &dc, image_width, image_height);
    defer i.destroy(testing.allocator);

    try h.add_image(i);
    try testing.expectEqual(1, h.map.count());

    const v = h.map.get(0);
    try testing.expectEqual(HistogramEntry{
        .color = [4]u8{ 0, 0, 0, 0 },
        .weight = image_height * image_width,
    }, v);
}
