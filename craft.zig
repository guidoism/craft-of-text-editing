const std = @import("std");

const Buffer = struct {
    name: [64]u8 = undefined,
    contents: std.ArrayList(u21),
    point: u32 = 0,
};

const World = std.ArrayList(Buffer);

const Window = struct {
    buffer: *Buffer,
    height: u16,
    width:  u16,
};

pub fn main() !void {
    //const stdout = std.io.getStdOut().writer();
    //try stdout.print("Hello, {s}!\n", .{"world"});
    
    var world = World;
    var b = world.addOne();
    b.contents.appendSlice("guido");
}



