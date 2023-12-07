const std = @import("std");
const print = std.debug.print;

const failedToDrive = error{noTiresError, negativeHorsepowerError};

const car  = struct{
    year: u32,
    hp: u32,
    ntires: u32,
    name: []u8,
    alloc: std.mem.Allocator = std.heap.page_allocator,

    pub fn drive(self: *const car) !void {
        if(self.ntires == 0) { return failedToDrive.noTiresError; }
        if(self.hp < 0) { return failedToDrive.negativeHorsepowerError; }

        var out = try self.alloc.alloc(u8, self.hp+3);
        defer self.alloc.free(out);

        out[0] = 'v';
        out[1] = 'r';
        for (0 .. self.hp+1) |i| {
            out[i+2] = 'o';
        }
        out[self.hp+2] = 'm';

        print("the {s} goes {s}\n", .{self.name, out});
    }
};

pub fn main() !void {
    var name = "accord".*;
    const mycar = car{.year = 2005, .hp = 35, .ntires = 3, .name = &name};
    mycar.drive() catch |err| {
        switch (err) {
            failedToDrive.noTiresError => print("{s} cannot drive without tires\n", .{mycar.name}),
            failedToDrive.negativeHorsepowerError => print("{s} has negative horsepower!. refer to driveBackwards()\n", .{mycar.name}),
            else => print("unknown error\n", .{}),
        }
        return;
    };
}
