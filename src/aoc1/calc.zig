const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn calc1(alloc: std.mem.Allocator) !i32 {
    var parsed1 = std.ArrayList(i32).init(alloc);
    defer parsed1.deinit();
    var parsed2 = std.ArrayList(i32).init(alloc);
    defer parsed2.deinit();

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        var nums = std.mem.splitSequence(u8, line, "   ");
        const n1 = nums.next().?;
        const num1: i32 = try std.fmt.parseInt(i32, n1, 10);
        try parsed1.append(num1);
        const n2 = nums.next().?;
        const num2: i32 = try std.fmt.parseInt(i32, n2, 10);
        try parsed2.append(num2);
    }

    std.mem.sort(i32, parsed1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, parsed2.items, {}, comptime std.sort.asc(i32));

    var sum: i32 = 0;
    for (0..parsed1.items.len) |i| {
        sum += @intCast(@abs(parsed2.items[i] - parsed1.items[i]));
    }

    return sum;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var parsed1 = std.ArrayList(i32).init(alloc);
    defer parsed1.deinit();
    var occurences = std.AutoHashMap(i32, i32).init(alloc);
    defer occurences.deinit();

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        var nums = std.mem.splitSequence(u8, line, "   ");
        const n1 = nums.next().?;
        const num1: i32 = try std.fmt.parseInt(i32, n1, 10);
        try parsed1.append(num1);
        const n2 = nums.next().?;
        const num2: i32 = try std.fmt.parseInt(i32, n2, 10);
        try occurences.put(num2, (occurences.get(num2) orelse 0) + 1);
    }

    var sim: i32 = 0;
    for (0..parsed1.items.len) |i| {
        sim += parsed1.items[i] * (occurences.get(parsed1.items[i]) orelse 0);
    }

    return sim;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
