const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn isValid1(towels: *[][]const u8, pattern: []const u8) bool {
    if (pattern.len == 0) {
        return true;
    }
    for (towels.*) |towel| {
        if (towel.len > pattern.len) {
            continue;
        }
        if (std.mem.eql(u8, towel, pattern[0..towel.len])) {
            // std.debug.print("testing: {s}\n", .{pattern[towel.len..]});
            if (isValid1(towels, pattern[towel.len..])) {
                return true;
            }
        }
    }
    return false;
}

fn calc1(alloc: std.mem.Allocator) !i64 {
    var towels = std.ArrayList([]const u8).init(alloc);
    defer towels.deinit();

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    const first = lines.next().?;
    var split = std.mem.tokenizeAny(u8, first, ", ");
    while (split.next()) |towel| {
        try towels.append(towel);
    }

    var patterns = std.ArrayList([]const u8).init(alloc);
    defer patterns.deinit();
    while (lines.next()) |line| {
        try patterns.append(line);
    }

    var count: i64 = 0;
    for (patterns.items) |pattern| {
        if (isValid1(&towels.items, pattern)) {
            // std.debug.print("valid: {s}\n", .{pattern});
            count += 1;
        }
    }

    return count;
}

fn countValid2(towels: *[][]const u8, pattern: []const u8, memo: *std.StringHashMap(i64)) std.mem.Allocator.Error!i64 {
    if (pattern.len == 0) {
        return 1;
    }
    if (memo.get(pattern)) |c| {
        return c;
    }
    var count: i64 = 0;
    for (towels.*) |towel| {
        if (towel.len > pattern.len) {
            continue;
        }
        if (std.mem.eql(u8, towel, pattern[0..towel.len])) {
            count += try countValid2(towels, pattern[towel.len..], memo);
        }
    }
    try memo.put(pattern, count);
    return count;
}

fn calc2(alloc: std.mem.Allocator) !i64 {
    var towels = std.ArrayList([]const u8).init(alloc);
    defer towels.deinit();

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    const first = lines.next().?;
    var split = std.mem.tokenizeAny(u8, first, ", ");
    while (split.next()) |towel| {
        try towels.append(towel);
    }

    var patterns = std.ArrayList([]const u8).init(alloc);
    defer patterns.deinit();
    while (lines.next()) |line| {
        try patterns.append(line);
    }

    var memo = std.StringHashMap(i64).init(alloc);
    defer memo.deinit();
    var count: i64 = 0;
    for (patterns.items) |pattern| {
        count += try countValid2(&towels.items, pattern, &memo);
    }

    return count;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
