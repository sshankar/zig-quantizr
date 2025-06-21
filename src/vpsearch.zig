const std = @import("std");
const mem = std.mem;

pub const SearchIndex = struct {
    index: u8,
    data: [4]f32,
};

pub const SearchNode = struct {
    index: *SearchIndex,
    near: ?*SearchNode,
    far: ?*SearchNode,
    rest: std.ArrayList(*SearchIndex),
    radius: f32,
    radius_sq: f32,

    pub fn new(alloc: mem.Allocator, indexes: *std.ArrayList(*SearchIndex), weights: []f32) !?*SearchNode {
        if (indexes.items.len == 0) {
            return null;
        }

        if (indexes.items.len == 1) {
            const node = try alloc.create(SearchNode);
            const ra = std.ArrayList(*SearchIndex).init(alloc);
            node.* = SearchNode{
                .index = indexes.pop().?,
                .near = null,
                .far = null,
                .rest = ra,
                .radius = std.math.floatMax(f32),
                .radius_sq = std.math.floatMax(f32),
            };
            return node;
        }

        var max_weight: f32 = weights[indexes.items[0].index];
        var max_idx: usize = 0;
        for (indexes.items, 0..) |ind, i| {
            const weight = weights[ind.index];
            if (@max(weight, max_weight) == weight) {
                max_weight = weight;
                max_idx = i;
            }
        }

        if (max_idx == -1) unreachable;
        const vp_ind = indexes.orderedRemove(max_idx);

        const cf = struct {
            pub fn call(c: *SearchIndex, a: *SearchIndex, b: *SearchIndex) bool {
                return distance(c.data, a.data) < distance(c.data, b.data);
            }
        }.call;

        std.sort.pdq(*SearchIndex, indexes.items, vp_ind, cf);

        const node = try alloc.create(SearchNode);
        if (indexes.items.len < 7) {
            var rest = std.ArrayList(*SearchIndex).init(alloc);
            try rest.appendSlice(indexes.items);
            node.* = SearchNode{
                .index = vp_ind,
                .near = null,
                .far = null,
                .rest = rest,
                .radius = std.math.floatMax(f32),
                .radius_sq = std.math.floatMax(f32),
            };
            return node;
        }

        const hi = indexes.items.len / 2;

        var ni = std.ArrayList(*SearchIndex).init(alloc);
        try ni.appendSlice(indexes.items[0..hi]);
        const nsn = try SearchNode.new(alloc, &ni, weights);

        var fi = std.ArrayList(*SearchIndex).init(alloc);
        try fi.appendSlice(indexes.items[hi..]);
        const fsn = try SearchNode.new(alloc, &fi, weights);

        const rest = std.ArrayList(*SearchIndex).init(alloc);
        const radius_sq = distance(vp_ind.data, fi.items[0].data);

        node.* = SearchNode{
            .index = vp_ind,
            .near = nsn,
            .far = fsn,
            .rest = rest,
            .radius_sq = radius_sq,
            .radius = std.math.sqrt(radius_sq),
        };
        return node;
    }

    pub fn deinit(self: *SearchNode, alloc: mem.Allocator) void {
        self.rest.deinit();

        if (self.far) |far| far.deinit(alloc);
        if (self.near) |near| near.deinit(alloc);

        alloc.destroy(self);
    }
};

// metric space distance function
pub fn distance(a: [4]f32, b: [4]f32) f32 {
    const av: @Vector(4, f32) = a;
    const bv: @Vector(4, f32) = b;

    const diff = av - bv;
    const mul = diff * diff;

    return @reduce(.Add, mul);
}
