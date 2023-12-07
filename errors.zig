const std = @import("std");
const print = std.debug.print;

const medianError = error{noMiddleElem, emptyArray};

pub fn median(comptime T: type, comptime n: usize, arr: [n]T) medianError!T {
    if (n == 0) { return medianError.emptyArray; }
    if (n % 2 == 0) { return medianError.noMiddleElem; }
    return arr[n/2];
}


pub fn main() !void {
    const b = [_]u8{5, 11, 12, 12, 11, 5};
    const bmid = median(u8, b.len, b) catch |err| {
        print("{s} has no median!!! [failed with {}]", .{b, err});
        return;
    };
    print("end of main: {}\n", .{bmid});
}