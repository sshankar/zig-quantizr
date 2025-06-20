// metric space distance function
pub fn distance(a: [4]f32, b: [4]f32) f32 {
    const av: @Vector(4, f32) = a;
    const bv: @Vector(4, f32) = b;

    const diff = av - bv;
    const mul = diff * diff;

    return @reduce(.Add, mul);
}
