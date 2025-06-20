const testing = @import("std").testing;
const math = @import("std").math;

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
