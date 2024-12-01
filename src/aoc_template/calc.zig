const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn calc1(alloc: std.mem.Allocator) !i32 {
    _ = alloc; // autofix
    return 0;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    _ = alloc; // autofix
    return 0;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
