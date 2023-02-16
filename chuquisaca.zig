const std = @import("std");
const Error = error{failed,OutOfMemory};
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const Buffer = struct {
    name: std.ArrayList(u8),
    fn create(name: []const u8) Error!Buffer {
        var b = Buffer{.name=std.ArrayList(u8).init(allocator)};
        try b.name.appendSlice(name);
        return b;
    }
};

pub fn main() !void {
}

test "Create buffer" {
    var buffers = std.ArrayList(Buffer).init(allocator);
    var b = buffers.addOne();
    //var b = try Buffer.create("*scratch*");
    std.debug.print("{any}\n", .{b});
    //std.debug.print("{s}\n", .{b.name.items});
    //try std.testing.expectError(Error.failed, Buffer.create("*scratch*"));
}
