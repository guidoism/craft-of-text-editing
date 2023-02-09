const std = @import("std");

const Buffer = struct {
    name: [64]u8 = undefined,
    contents: std.ArrayList(u21),
    point: u32 = 0,
};

const Window = struct {
    buffer: u16,
    height: u16,
    width:  u16,
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var arena_state = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena_state.deinit();
    const allocator = arena_state.allocator();
    var world = std.ArrayList(Buffer).init(allocator);
    var b = world.addOne();
    stdout.print("{d}\n", .{b.point});
    //b.contents.appendSlice("guido");
    // var window = Window { .height=80, .width=25 };
}



