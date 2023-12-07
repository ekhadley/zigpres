const std = @import("std");
const print = std.debug.print;

pub fn matrix(alloc: std.mem.Allocator, comptime n: usize, comptime T: type) ![][n]T {
    var m: [][n]T = try alloc.alloc([n]T, n);

    const e: T = 0;
    for (0..n) |j|{
        for (0..n) |i| {
            m[j][i] = e;
        }
    }
    return m;
}

pub fn morebits(comptime T: type)

pub fn main() !void {
    @setRuntimeSafety(true);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const known: f64 = 3.0;
    const m = try matrix(alloc, known, f32);

    print("{d}\n", .{m});
    print("{d}\n", .{m[0]});
    print("{d}\n", .{m[0][1]});
}