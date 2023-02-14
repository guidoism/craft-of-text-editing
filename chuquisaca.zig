const std = @import("std");
const Error = error{failed,OutOfMemory};
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const Buffer = struct {
    name: std.ArrayList(u8),
    fn create(name: []const u8) Error!Buffer {
        var b = Buffer{.name=std.ArrayList(u8).init(allocator)};
        //std.mem.copy(u8, &b.name, name);
        //b.name[5] = 0;
        try b.name.appendSlice(name);
        
        return b;
    }
};

pub fn main() !void {
    var b = try Buffer.create("*scratch*");
    std.debug.print("{s}\n", .{b.name.items});
}

