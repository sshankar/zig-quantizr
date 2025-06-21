const std = @import("std");
const mem = std.mem;

const Image = @import("image.zig").Image;

pub const HistogramEntry = struct {
    color: [4]u8,
    weight: u32,
};

pub const Histogram = struct {
    map: std.AutoHashMap(u64, HistogramEntry),

    pub fn new(allocator: mem.Allocator) !*Histogram {
        const m = std.AutoHashMap(u64, HistogramEntry).init(allocator);
        const h = try allocator.create(Histogram);
        h.* = Histogram{
            .map = m,
        };
        return h;
    }

    pub fn add_image(self: *Histogram, image: *const Image) anyerror!void {
        const s = image.width * image.height;

        var i: u32 = 0;
        while (i < s * 4) : (i += 4) {
            const pix = image.data[i .. i + 4];

            var col = [4]u8{ 0, 0, 0, 0 };
            if (pix[3] != 0) {
                @memcpy(&col, pix);
            }

            const key: u64 = @as(u64, std.mem.readInt(u32, &col, .little));
            if (self.map.getPtr(key)) |vp| {
                vp.*.weight +|= 1;
            } else {
                try self.map.put(key, HistogramEntry{
                    .color = col,
                    .weight = 1,
                });
            }
        }
    }

    pub fn destroy(self: *Histogram, allocator: mem.Allocator) void {
        self.map.deinit();
        allocator.destroy(self);
    }
};
