const std = @import("std");
const print = std.debug.print;


pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var args = try std.process.argsWithAllocator(alloc);

        print("{}, {}", .{args, @TypeOf(args)});
    while (args.next()) |arg| {
        print("{s}, ", .{arg});
    }
}