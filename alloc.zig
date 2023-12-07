const std = @import("std");
const print = std.debug.print;


pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{.verbose_log=true}){};
    const alloc = gpa.allocator();
    defer gpa.deinit();

    var mem = try alloc.alloc(u8, 10);
    defer alloc.dealloc(mem);

    var i: u8 = 0;
    for (0..mem.len) |j| {
        mem[j] = i;
        print("{}", .{i});
        i += 1;
    }
    print("{s}, {}, {}", .{mem, @TypeOf(mem), mem.len});
}