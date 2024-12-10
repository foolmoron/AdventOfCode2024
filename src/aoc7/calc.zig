const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn isValid1(total: u64, curr: u64, remaining: []u64) bool {
    if (remaining.len == 0) {
        return curr == total;
    }
    return isValid1(total, curr + remaining[0], remaining[1..]) or isValid1(total, curr * remaining[0], remaining[1..]);
}

fn calc1(alloc: std.mem.Allocator) !u64 {
    var sum: u64 = 0;

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        var totalSplit = std.mem.tokenizeSequence(u8, line, ": ");
        const total = try std.fmt.parseInt(u64, totalSplit.next().?, 10);
        var numsSplit = std.mem.tokenizeAny(u8, totalSplit.next().?, " ");
        var nums = std.ArrayList(u64).init(alloc);
        defer nums.deinit();
        while (numsSplit.next()) |num| {
            const n = try std.fmt.parseInt(u64, num, 10);
            try nums.append(n);
        }

        const valid = isValid1(total, nums.items[0], nums.items[1..]);
        if (valid) {
            sum += total;
        }
    }
    return sum;
}

fn isValid2(total: u64, curr: u64, remaining: []u64) bool {
    if (remaining.len == 0) {
        return curr == total;
    }
    if (isValid2(total, curr + remaining[0], remaining[1..]) or isValid2(total, curr * remaining[0], remaining[1..])) {
        return true;
    } else {
        const digits = std.math.log10(remaining[0]) + 1;
        const new = curr * (std.math.powi(u64, 10, digits) catch unreachable) + remaining[0];
        return isValid2(total, new, remaining[1..]);
    }
}

fn calc2(alloc: std.mem.Allocator) !u64 {
    var sum: u64 = 0;

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        var totalSplit = std.mem.tokenizeSequence(u8, line, ": ");
        const total = try std.fmt.parseInt(u64, totalSplit.next().?, 10);
        var numsSplit = std.mem.tokenizeAny(u8, totalSplit.next().?, " ");
        var nums = std.ArrayList(u64).init(alloc);
        defer nums.deinit();
        while (numsSplit.next()) |num| {
            const n = try std.fmt.parseInt(u64, num, 10);
            try nums.append(n);
        }

        const valid = isValid2(total, nums.items[0], nums.items[1..]);
        if (valid) {
            sum += total;
        }
    }
    return sum;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
