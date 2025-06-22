const std = @import("std");
const testing = std.testing;
const math = std.math;

const vps = @import("vpsearch.zig");

test "distance function - non negativity" {
    const a = [4]f32{ 225, 100, 64, 225 };
    const b = [4]f32{ 220, 64, 100, 225 };

    try testing.expect(vps.distance(a, b) > 0);
    try testing.expect(vps.distance(b, a) > 0);
}

test "distance function - symmetry" {
    const a = [4]f32{ 225, 100, 64, 225 };
    const b = [4]f32{ 220, 64, 100, 225 };

    try testing.expectEqual(vps.distance(a, b), vps.distance(b, a));
}

test "distance function - zero" {
    const a = [4]f32{ 225, 100, 64, 225 };

    try testing.expectEqual(0, vps.distance(a, a));
}

test "distance function - triangle inequality" {
    const a = [4]f32{ 225, 100, 64, 225 };
    const b = [4]f32{ 220, 64, 100, 225 };
    const c = [4]f32{ 100, 220, 64, 225 };

    const dab = vps.distance(a, b);
    const dbc = vps.distance(b, c);
    const dac = vps.distance(a, c);

    try testing.expect(dac <= (dab + dbc));
}

test "distance function - math validity" {
    const a = [4]f32{ 225, 100, 64, 225 };
    const b = [4]f32{ 100, 220, 64, 225 };

    try testing.expectEqual(distance_std(a, b), vps.distance(a, b));
}

fn distance_std(a: [4]f32, b: [4]f32) f32 {
    return math.pow(f32, (a[0] - b[0]), 2.0) +
        math.pow(f32, (a[1] - b[1]), 2.0) +
        math.pow(f32, (a[2] - b[2]), 2.0) +
        math.pow(f32, (a[3] - b[3]), 2.0);
}

test "search node - empty" {
    var indexes = std.ArrayList(*vps.SearchIndex).init(testing.allocator);
    const weights = [0]f32{};

    const res = vps.SearchNode.init(testing.allocator, &indexes, &weights) catch unreachable;
    if (res) |_| {
        unreachable;
    }
}

test "search node - 6 nodes" {
    var td = GenerateTestData(5){};
    try td.init(testing.allocator);
    defer td.deinit(testing.allocator);

    var indexes = std.ArrayList(*vps.SearchIndex).init(testing.allocator);
    defer indexes.deinit();
    try indexes.appendSlice(&td.indarr);

    const r: ?*vps.SearchNode = try vps.SearchNode.init(testing.allocator, &indexes, &td.weights);
    if (r) |rv| {
        defer rv.deinit(testing.allocator);

        try testing.expect(rv.far == null);
        try testing.expect(rv.near == null);
        try testing.expectEqual(std.math.floatMax(f32), rv.radius);
        try testing.expectEqual(std.math.floatMax(f32), rv.radius_sq);
        try testing.expectEqual(4, rv.rest.items.len);
        try testing.expectEqual(td.indarr[4], rv.index);
    } else {
        unreachable;
    }
}

test "search node - 18 nodes" {
    var td = GenerateTestData(18){};
    try td.init(testing.allocator);
    defer td.deinit(testing.allocator);

    var indexes = std.ArrayList(*vps.SearchIndex).init(testing.allocator);
    defer indexes.deinit();
    try indexes.appendSlice(&td.indarr);

    const r: ?*vps.SearchNode = try vps.SearchNode.init(testing.allocator, &indexes, &td.weights);
    if (r) |rv| {
        defer rv.deinit(testing.allocator);

        try testing.expectEqual(17, rv.index.index);
    } else {
        unreachable;
    }
}

test "search visitor - set" {
    const sn = try testing.allocator.create(vps.SearchIndex);
    defer testing.allocator.destroy(sn);

    sn.* = vps.SearchIndex{
        .data = [4]f32{ 1, 2, 3, 4 },
        .index = 1,
    };

    const sv = try vps.SearchVisitor.init(testing.allocator);
    defer sv.deinit(testing.allocator);

    sv.visit(sn, 4);

    try testing.expectEqual(4, sv.distance_sq);
    try testing.expectEqual(2, sv.distance);
    try testing.expectEqual(sn, sv.index);
}

test "search visitor - override" {
    const sn = try testing.allocator.create(vps.SearchIndex);
    defer testing.allocator.destroy(sn);
    sn.* = vps.SearchIndex{
        .data = [4]f32{ 1, 2, 3, 4 },
        .index = 1,
    };

    const sv = try vps.SearchVisitor.init(testing.allocator);
    defer sv.deinit(testing.allocator);

    sv.visit(sn, 16);

    try testing.expectEqual(16, sv.distance_sq);
    try testing.expectEqual(4, sv.distance);
    try testing.expectEqual(sn, sv.index);

    const sns = try testing.allocator.create(vps.SearchIndex);
    defer testing.allocator.destroy(sns);
    sns.* = vps.SearchIndex{
        .data = [4]f32{ 1, 2, 3, 4 },
        .index = 1,
    };

    sv.visit(sns, 4);

    try testing.expectEqual(4, sv.distance_sq);
    try testing.expectEqual(2, sv.distance);
    try testing.expectEqual(sns, sv.index);
}

test "search - absolute" {
    var td = GenerateTestData(18){};
    try td.init(testing.allocator);
    defer td.deinit(testing.allocator);

    var indexes = std.ArrayList(*vps.SearchIndex).init(testing.allocator);
    defer indexes.deinit();
    try indexes.appendSlice(&td.indarr);

    const r: ?*vps.SearchNode = try vps.SearchNode.init(testing.allocator, &indexes, &td.weights);
    if (r) |rv| {
        defer rv.deinit(testing.allocator);

        const sv = try vps.SearchVisitor.init(testing.allocator);
        defer sv.deinit(testing.allocator);

        const pin = [4]f32{ 1, 2, 3, 4 };

        rv.accept(pin, @constCast(sv));
        try testing.expectEqual(pin, sv.index.?.data);
        try testing.expectEqual(0, sv.index.?.index);
        try testing.expectEqual(0, sv.distance);
        try testing.expectEqual(0, sv.distance_sq);
    } else {
        unreachable;
    }
}

test "search - nearest" {
    var td = GenerateTestData(18){};
    try td.init(testing.allocator);
    defer td.deinit(testing.allocator);

    var indexes = std.ArrayList(*vps.SearchIndex).init(testing.allocator);
    defer indexes.deinit();
    try indexes.appendSlice(&td.indarr);

    const r: ?*vps.SearchNode = try vps.SearchNode.init(testing.allocator, &indexes, &td.weights);
    if (r) |rv| {
        defer rv.deinit(testing.allocator);

        const sv = try vps.SearchVisitor.init(testing.allocator);
        defer sv.deinit(testing.allocator);

        const pin = [4]f32{ 23, 24, 25, 26 }; // > 18+3
        const closest = td.indarr[17];
        const dist = distance_std(pin, closest.data);

        rv.accept(pin, @constCast(sv));
        try testing.expectEqual(closest, sv.index.?);
        try testing.expectEqual(math.sqrt(dist), sv.distance);
        try testing.expectEqual(dist, sv.distance_sq);
    } else {
        unreachable;
    }
}

test "search tree - nearest absolute" {
    var td = GenerateTestData(18){};
    try td.init(testing.allocator);
    defer td.deinit(testing.allocator);

    var indexes = std.ArrayList(*vps.SearchIndex).init(testing.allocator);
    defer indexes.deinit();
    try indexes.appendSlice(&td.indarr);

    const pin = [4]f32{ 1, 2, 3, 4 };
    const closest = td.indarr[0];
    const dist = distance_std(pin, closest.data);

    const tree = try vps.SearchTree.init(testing.allocator, &indexes, &td.weights);
    defer tree.deinit(testing.allocator);
    const nd = try tree.find_nearest(testing.allocator, pin);

    try testing.expectEqual(closest.index, nd.index);
    try testing.expectEqual(math.sqrt(dist), nd.distance);
    try testing.expectEqual(closest.data, nd.data);
}

fn GenerateTestData(comptime length: usize) type {
    return struct {
        indarr: [length]*vps.SearchIndex = undefined,
        weights: [length]f32 = undefined,

        fn init(self: *GenerateTestData(length), allocator: std.mem.Allocator) !void {
            for (0..length) |idx| {
                self.weights[idx] = @as(f32, @floatFromInt(idx));
                const si = try allocator.create(vps.SearchIndex);
                si.* = vps.SearchIndex{
                    .data = [4]f32{
                        @as(f32, @floatFromInt(idx + 1)),
                        @as(f32, @floatFromInt(idx + 2)),
                        @as(f32, @floatFromInt(idx + 3)),
                        @as(f32, @floatFromInt(idx + 4)),
                    },
                    .index = @intCast(idx),
                };
                self.indarr[idx] = si;
            }
        }

        fn deinit(self: *GenerateTestData(length), allocator: std.mem.Allocator) void {
            for (self.indarr) |i| {
                allocator.destroy(i);
            }
        }
    };
}
