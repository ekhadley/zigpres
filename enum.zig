const std = @import("std");
const print = std.debug.print;

const student = enum(u32){ freshman, var sophomore, junior, senior, supersenior=1_000_000, hypersenior };

pub fn main() !void {
    print("student: {}, {}, {}, {}\n", .{student, @TypeOf(student), @TypeOf(student.sophomore), @intFromEnum(student.sophomore)});
    
    const ethan = student.senior;
    print("ethan: {}, {},  {}\n", .{ethan, @TypeOf(ethan), @intFromEnum(ethan)});
    
    const nahte = student.supersenior;
    print("nahte: {}, {},  {}\n", .{nahte, @TypeOf(nahte), @intFromEnum(nahte)});

    const xX_EtHaN_Xx = student.hypersenior;
    print("xX_EtHaN_Xx: {}, {},  {}\n", .{xX_EtHaN_Xx, @TypeOf(xX_EtHaN_Xx), @intFromEnum(xX_EtHaN_Xx)});
}