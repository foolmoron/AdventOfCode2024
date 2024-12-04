const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn isLineSafe(alloc: std.mem.Allocator, line: []const u8, ignoreIdx: usize) !bool {
    var nums = std.ArrayList(i32).init(alloc);
    defer nums.deinit();

    var split = std.mem.splitSequence(u8, line, " ");
    while (split.next()) |num| {
        const n: i32 = try std.fmt.parseInt(i32, num, 10);
        try nums.append(n);
    }

    if (ignoreIdx >= 0 and ignoreIdx < nums.items.len) {
        _ = nums.orderedRemove(ignoreIdx);
    }

    const ns = nums.items;
    var safe = true;

    if (ns[0] < ns[1]) {
        for (1..ns.len) |i| {
            safe = safe and ns[i - 1] < ns[i] and (ns[i] - ns[i - 1]) >= 1 and (ns[i] - ns[i - 1]) <= 3;
        }
    } else {
        for (1..ns.len) |i| {
            safe = safe and ns[i - 1] > ns[i] and (ns[i - 1] - ns[i]) >= 1 and (ns[i - 1] - ns[i]) <= 3;
        }
    }
    return safe;
}

fn calc1(alloc: std.mem.Allocator) !i32 {
    var count: i32 = 0;
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        const safe = try isLineSafe(alloc, line, 99);
        if (safe) {
            count += 1;
        }
    }
    return count;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var count: i32 = 0;
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        for (0..10) |i| {
            const safe = try isLineSafe(alloc, line, i);
            if (safe) {
                count += 1;
                break;
            }
        }
    }
    return count;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
