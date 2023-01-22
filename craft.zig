const std = @import("std");

const Buffer = struct {
    name: [64]u8,
    contents: std.ArrayList(u21),
    point: u32,
};

fn CircularList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: T,
        };

        first: ?*Node,
        last:  ?*Node,
        len:   usize,
    };
}

const World = struct {
    chain: CircularList(Buffer),
    current: ?*CircularList(Buffer).Node,
};

var world = World();

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, {s}!\n", .{"world"});
}



