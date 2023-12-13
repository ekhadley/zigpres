const std = @import("std");
const print = std.debug.print;

const medianError = error{noMiddleElem, emptyArray};

pub fn median(comptime T: type, comptime n: usize, arr: [n]T) medianError!T {
    if (n == 0) { return medianError.emptyArray; }
    if (n % 2 == 0) { return medianError.noMiddleElem; }
    return arr[n/2];
}


pub fn main() !void {
    const a = [_]f32{4, 5, 6, 7, 8};
    
    const middle = try median(f32, a.len, a);
    print("mid: {d}, {}\n", .{middle, @TypeOf(middle)});
}