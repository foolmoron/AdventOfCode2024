const std = @import("std");

const INPUT = @embedFile("./input.txt");

const StartEnd = struct {
    start: u8,
    end: u8,
};

fn calc1(alloc: std.mem.Allocator) !i32 {
    var numMap = std.AutoHashMap(StartEnd, []const u8).init(alloc);
    defer numMap.deinit();
    try numMap.put(StartEnd{ .start = 'A', .end = 'A' }, "");
    try numMap.put(StartEnd{ .start = 'A', .end = '0' }, "<");
    try numMap.put(StartEnd{ .start = 'A', .end = '1' }, "^<<");
    try numMap.put(StartEnd{ .start = 'A', .end = '2' }, "^<");
    try numMap.put(StartEnd{ .start = 'A', .end = '3' }, "^");
    try numMap.put(StartEnd{ .start = 'A', .end = '4' }, "^^<<");
    try numMap.put(StartEnd{ .start = 'A', .end = '5' }, "^^<");
    try numMap.put(StartEnd{ .start = 'A', .end = '6' }, "^^");
    try numMap.put(StartEnd{ .start = 'A', .end = '7' }, "^^^<<");
    try numMap.put(StartEnd{ .start = 'A', .end = '8' }, "^^^<");
    try numMap.put(StartEnd{ .start = 'A', .end = '9' }, "^^^");
    try numMap.put(StartEnd{ .start = '0', .end = 'A' }, ">");
    try numMap.put(StartEnd{ .start = '0', .end = '0' }, "");
    try numMap.put(StartEnd{ .start = '0', .end = '1' }, "^<");
    try numMap.put(StartEnd{ .start = '0', .end = '2' }, "^");
    try numMap.put(StartEnd{ .start = '0', .end = '3' }, "^>");
    try numMap.put(StartEnd{ .start = '0', .end = '4' }, "^^<");
    try numMap.put(StartEnd{ .start = '0', .end = '5' }, "^^");
    try numMap.put(StartEnd{ .start = '0', .end = '6' }, "^^>");
    try numMap.put(StartEnd{ .start = '0', .end = '7' }, "^^^<");
    try numMap.put(StartEnd{ .start = '0', .end = '8' }, "^^^");
    try numMap.put(StartEnd{ .start = '0', .end = '9' }, "^^^>");
    try numMap.put(StartEnd{ .start = '1', .end = 'A' }, ">>v");
    try numMap.put(StartEnd{ .start = '1', .end = '0' }, ">v");
    try numMap.put(StartEnd{ .start = '1', .end = '1' }, "");
    try numMap.put(StartEnd{ .start = '1', .end = '2' }, ">");
    try numMap.put(StartEnd{ .start = '1', .end = '3' }, ">>");
    try numMap.put(StartEnd{ .start = '1', .end = '4' }, "^");
    try numMap.put(StartEnd{ .start = '1', .end = '5' }, "^>");
    try numMap.put(StartEnd{ .start = '1', .end = '6' }, "^>>");
    try numMap.put(StartEnd{ .start = '1', .end = '7' }, "^^");
    try numMap.put(StartEnd{ .start = '1', .end = '8' }, "^^>");
    try numMap.put(StartEnd{ .start = '1', .end = '9' }, "^^>>");
    try numMap.put(StartEnd{ .start = '2', .end = 'A' }, ">v");
    try numMap.put(StartEnd{ .start = '2', .end = '0' }, "v");
    try numMap.put(StartEnd{ .start = '2', .end = '1' }, "<");
    try numMap.put(StartEnd{ .start = '2', .end = '2' }, "");
    try numMap.put(StartEnd{ .start = '2', .end = '3' }, ">");
    try numMap.put(StartEnd{ .start = '2', .end = '4' }, "^<");
    try numMap.put(StartEnd{ .start = '2', .end = '5' }, "^");
    try numMap.put(StartEnd{ .start = '2', .end = '6' }, "^>");
    try numMap.put(StartEnd{ .start = '2', .end = '7' }, "^^<");
    try numMap.put(StartEnd{ .start = '2', .end = '8' }, "^^");
    try numMap.put(StartEnd{ .start = '2', .end = '9' }, "^^>");
    try numMap.put(StartEnd{ .start = '3', .end = 'A' }, "v");
    try numMap.put(StartEnd{ .start = '3', .end = '0' }, "v<");
    try numMap.put(StartEnd{ .start = '3', .end = '1' }, "<<");
    try numMap.put(StartEnd{ .start = '3', .end = '2' }, "<");
    try numMap.put(StartEnd{ .start = '3', .end = '3' }, "");
    try numMap.put(StartEnd{ .start = '3', .end = '4' }, "^<<");
    try numMap.put(StartEnd{ .start = '3', .end = '5' }, "^<");
    try numMap.put(StartEnd{ .start = '3', .end = '6' }, "^");
    try numMap.put(StartEnd{ .start = '3', .end = '7' }, "^^<<");
    try numMap.put(StartEnd{ .start = '3', .end = '8' }, "^^<");
    try numMap.put(StartEnd{ .start = '3', .end = '9' }, "^^");
    try numMap.put(StartEnd{ .start = '4', .end = 'A' }, ">>vv");
    try numMap.put(StartEnd{ .start = '4', .end = '0' }, ">vv");
    try numMap.put(StartEnd{ .start = '4', .end = '1' }, "v");
    try numMap.put(StartEnd{ .start = '4', .end = '2' }, ">v");
    try numMap.put(StartEnd{ .start = '4', .end = '3' }, ">>v");
    try numMap.put(StartEnd{ .start = '4', .end = '4' }, "");
    try numMap.put(StartEnd{ .start = '4', .end = '5' }, ">");
    try numMap.put(StartEnd{ .start = '4', .end = '6' }, ">>");
    try numMap.put(StartEnd{ .start = '4', .end = '7' }, "^");
    try numMap.put(StartEnd{ .start = '4', .end = '8' }, "^>");
    try numMap.put(StartEnd{ .start = '4', .end = '9' }, "^>>");
    try numMap.put(StartEnd{ .start = '5', .end = 'A' }, ">vv");
    try numMap.put(StartEnd{ .start = '5', .end = '0' }, "vv");
    try numMap.put(StartEnd{ .start = '5', .end = '1' }, "v<");
    try numMap.put(StartEnd{ .start = '5', .end = '2' }, "v");
    try numMap.put(StartEnd{ .start = '5', .end = '3' }, "v>");
    try numMap.put(StartEnd{ .start = '5', .end = '4' }, "<");
    try numMap.put(StartEnd{ .start = '5', .end = '5' }, "");
    try numMap.put(StartEnd{ .start = '5', .end = '6' }, ">");
    try numMap.put(StartEnd{ .start = '5', .end = '7' }, "^<");
    try numMap.put(StartEnd{ .start = '5', .end = '8' }, "^");
    try numMap.put(StartEnd{ .start = '5', .end = '9' }, "^>");
    try numMap.put(StartEnd{ .start = '6', .end = 'A' }, "vv");
    try numMap.put(StartEnd{ .start = '6', .end = '0' }, "vv<");
    try numMap.put(StartEnd{ .start = '6', .end = '1' }, "v<<");
    try numMap.put(StartEnd{ .start = '6', .end = '2' }, "v<");
    try numMap.put(StartEnd{ .start = '6', .end = '3' }, "v");
    try numMap.put(StartEnd{ .start = '6', .end = '4' }, "<<");
    try numMap.put(StartEnd{ .start = '6', .end = '5' }, "<");
    try numMap.put(StartEnd{ .start = '6', .end = '6' }, "");
    try numMap.put(StartEnd{ .start = '6', .end = '7' }, "^<<");
    try numMap.put(StartEnd{ .start = '6', .end = '8' }, "^<");
    try numMap.put(StartEnd{ .start = '6', .end = '9' }, "^");
    try numMap.put(StartEnd{ .start = '7', .end = 'A' }, ">>vvv");
    try numMap.put(StartEnd{ .start = '7', .end = '0' }, ">vvv");
    try numMap.put(StartEnd{ .start = '7', .end = '1' }, "vv");
    try numMap.put(StartEnd{ .start = '7', .end = '2' }, ">vv");
    try numMap.put(StartEnd{ .start = '7', .end = '3' }, ">>vv");
    try numMap.put(StartEnd{ .start = '7', .end = '4' }, "v");
    try numMap.put(StartEnd{ .start = '7', .end = '5' }, "v>");
    try numMap.put(StartEnd{ .start = '7', .end = '6' }, "v>>");
    try numMap.put(StartEnd{ .start = '7', .end = '7' }, "");
    try numMap.put(StartEnd{ .start = '7', .end = '8' }, ">");
    try numMap.put(StartEnd{ .start = '7', .end = '9' }, ">>");
    try numMap.put(StartEnd{ .start = '8', .end = 'A' }, ">vvv");
    try numMap.put(StartEnd{ .start = '8', .end = '0' }, "vvv");
    try numMap.put(StartEnd{ .start = '8', .end = '1' }, "vv<");
    try numMap.put(StartEnd{ .start = '8', .end = '2' }, "vv");
    try numMap.put(StartEnd{ .start = '8', .end = '3' }, "vv>");
    try numMap.put(StartEnd{ .start = '8', .end = '4' }, "v<");
    try numMap.put(StartEnd{ .start = '8', .end = '5' }, "v");
    try numMap.put(StartEnd{ .start = '8', .end = '6' }, "v>");
    try numMap.put(StartEnd{ .start = '8', .end = '7' }, "<");
    try numMap.put(StartEnd{ .start = '8', .end = '8' }, "");
    try numMap.put(StartEnd{ .start = '8', .end = '9' }, ">");
    try numMap.put(StartEnd{ .start = '9', .end = 'A' }, "vvv");
    try numMap.put(StartEnd{ .start = '9', .end = '0' }, "vvv<");
    try numMap.put(StartEnd{ .start = '9', .end = '1' }, "vv<<");
    try numMap.put(StartEnd{ .start = '9', .end = '2' }, "vv<");
    try numMap.put(StartEnd{ .start = '9', .end = '3' }, "vv");
    try numMap.put(StartEnd{ .start = '9', .end = '4' }, "v<<");
    try numMap.put(StartEnd{ .start = '9', .end = '5' }, "v<");
    try numMap.put(StartEnd{ .start = '9', .end = '6' }, "v");
    try numMap.put(StartEnd{ .start = '9', .end = '7' }, "<<");
    try numMap.put(StartEnd{ .start = '9', .end = '8' }, "<");
    try numMap.put(StartEnd{ .start = '9', .end = '9' }, "");

    var dirMap = std.AutoHashMap(StartEnd, []const u8).init(alloc);
    defer dirMap.deinit();
    try dirMap.put(StartEnd{ .start = 'A', .end = 'A' }, "");
    try dirMap.put(StartEnd{ .start = 'A', .end = '^' }, "<");
    try dirMap.put(StartEnd{ .start = 'A', .end = '<' }, "v<<");
    try dirMap.put(StartEnd{ .start = 'A', .end = 'v' }, "v<");
    try dirMap.put(StartEnd{ .start = 'A', .end = '>' }, "v");
    try dirMap.put(StartEnd{ .start = '^', .end = 'A' }, ">");
    try dirMap.put(StartEnd{ .start = '^', .end = '^' }, "");
    try dirMap.put(StartEnd{ .start = '^', .end = '<' }, "v<");
    try dirMap.put(StartEnd{ .start = '^', .end = 'v' }, "v");
    try dirMap.put(StartEnd{ .start = '^', .end = '>' }, "v>");
    try dirMap.put(StartEnd{ .start = '<', .end = 'A' }, ">>^");
    try dirMap.put(StartEnd{ .start = '<', .end = '^' }, ">^");
    try dirMap.put(StartEnd{ .start = '<', .end = '<' }, "");
    try dirMap.put(StartEnd{ .start = '<', .end = 'v' }, ">");
    try dirMap.put(StartEnd{ .start = '<', .end = '>' }, ">>");
    try dirMap.put(StartEnd{ .start = 'v', .end = 'A' }, ">^");
    try dirMap.put(StartEnd{ .start = 'v', .end = '^' }, "^");
    try dirMap.put(StartEnd{ .start = 'v', .end = '<' }, "<");
    try dirMap.put(StartEnd{ .start = 'v', .end = 'v' }, "");
    try dirMap.put(StartEnd{ .start = 'v', .end = '>' }, ">");
    try dirMap.put(StartEnd{ .start = '>', .end = 'A' }, "^");
    try dirMap.put(StartEnd{ .start = '>', .end = '^' }, "^<");
    try dirMap.put(StartEnd{ .start = '>', .end = '<' }, "<<");
    try dirMap.put(StartEnd{ .start = '>', .end = 'v' }, "<");
    try dirMap.put(StartEnd{ .start = '>', .end = '>' }, "");

    var sum: i32 = 0;

    var steps = std.ArrayList([]const u8).init(alloc);
    defer steps.deinit();
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        std.debug.print("{s}:\n", .{line});

        steps.clearRetainingCapacity();
        var a1: u8 = 'A';
        for (0..line.len) |i| {
            const b1 = line[i];
            try steps.append(numMap.get(StartEnd{ .start = a1, .end = b1 }) orelse unreachable);
            try steps.append("A");
            a1 = b1;
        }
        const robot1 = try std.mem.join(alloc, "", steps.items);
        defer alloc.free(robot1);
        std.debug.print("{s}\n", .{robot1});

        steps.clearRetainingCapacity();
        var a2: u8 = 'A';
        for (0..robot1.len) |i| {
            const b2 = robot1[i];
            try steps.append(dirMap.get(StartEnd{ .start = a2, .end = b2 }) orelse unreachable);
            try steps.append("A");
            a2 = b2;
        }
        const robot2 = try std.mem.join(alloc, "", steps.items);
        defer alloc.free(robot2);
        std.debug.print("{s}\n", .{robot2});

        steps.clearRetainingCapacity();
        var a3: u8 = 'A';
        for (0..robot2.len) |i| {
            const b3 = robot2[i];
            try steps.append(dirMap.get(StartEnd{ .start = a3, .end = b3 }) orelse unreachable);
            try steps.append("A");
            a3 = b3;
        }
        const robot3 = try std.mem.join(alloc, "", steps.items);
        defer alloc.free(robot3);
        std.debug.print("{s}\n", .{robot3});

        const v1 = try std.fmt.parseInt(i32, line[0 .. line.len - 1], 10);
        const v2: i32 = @intCast(robot3.len);
        std.debug.print("{any} * {any}\n\n", .{ v1, v2 });
        sum += v1 * v2;
    }

    return sum;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    _ = alloc; // autofix
    return 0;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
