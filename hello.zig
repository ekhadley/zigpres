const std = @import("std");
const print = std.debug.print;


pub fn swap(a: *u8, b: *u8) void {
    const tmp: u8 = a.*;
    a.* = b.*;
    b.* = tmp;
}

pub fn heaps(word: []u8, n: usize) void {
    if (n == 0) {
        print("{s}\n", .{word});
    } else {
        for (0..n) |i| {
            heaps(word, n - 1);
            if (n % 2 == 0) {
                swap(&word[0], &word[n]);
            } else {
                swap(&word[i], &word[n]);
            }
        }
        heaps(word, n - 1);
    }
}

pub fn main() !void {
    var word = "zig".*;
    heaps(&word, word.len-1);
}