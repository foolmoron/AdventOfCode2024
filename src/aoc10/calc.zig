const std = @import("std");

const INPUT = @embedFile("./input.txt");
const w = blk: {
    var iter = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    const line = iter.next().?;
    break :blk line.len;
};
const h = blk: {
    @setEvalBranchQuota(10000);
    var count: usize = 0;
    var iter = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (iter.next()) |_| {
        count += 1;
    }
    break :blk count;
};

const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn toIndex(self: @This(), height: usize) usize {
        return @intCast(@as(i32, @intCast(height)) * self.y + self.x);
    }
};

fn gatherTrailsInSet1(grid: *[w * h]u8, set: *std.AutoHashMap(Vec2, void), pos: Vec2, valPrev: u8) !void {
    if (pos.x < 0 or pos.x >= w or pos.y < 0 or pos.y >= h) {
        return;
    }
    const val = grid[pos.toIndex(h)];
    if (val < valPrev or val - valPrev != 1) {
        return;
    }
    if (val == '9') {
        // std.debug.print("   found at {any}\n", .{pos});
        try set.put(pos, {});
        return;
    }
    for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
        const posNext = Vec2{ .x = pos.x + dir.x, .y = pos.y + dir.y };
        try gatherTrailsInSet1(grid, set, posNext, val);
    }
}

fn calc1(alloc: std.mem.Allocator) !i32 {
    var grid: [w * h]u8 = undefined;
    var pos = Vec2{};
    var trails = std.ArrayList(Vec2).init(alloc);
    defer trails.deinit();
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        for (line) |c| {
            grid[pos.toIndex(h)] = c;
            if (c == '0') {
                try trails.append(pos);
            }
            pos.x += 1;
        }
        pos.y += 1;
        pos.x = 0;
    }

    var sum: i32 = 0;
    for (trails.items) |start| {
        var set = std.AutoHashMap(Vec2, void).init(alloc);
        defer set.deinit();
        try gatherTrailsInSet1(&grid, &set, start, '0' - 1);
        const score = set.count();
        sum += @intCast(score);
        // std.debug.print("start {any} => {any}\n", .{ start, score });
    }

    return sum;
}

fn gatherTrailsInSet2(grid: *[w * h]u8, pos: Vec2, valPrev: u8) usize {
    if (pos.x < 0 or pos.x >= w or pos.y < 0 or pos.y >= h) {
        return 0;
    }
    const val = grid[pos.toIndex(h)];
    if (val < valPrev or val - valPrev != 1) {
        return 0;
    }
    if (val == '9') {
        // std.debug.print("   found at {any}\n", .{pos});
        return 1;
    }
    var count: usize = 0;
    for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
        const posNext = Vec2{ .x = pos.x + dir.x, .y = pos.y + dir.y };
        count += gatherTrailsInSet2(grid, posNext, val);
    }
    return count;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var grid: [w * h]u8 = undefined;
    var pos = Vec2{};
    var trails = std.ArrayList(Vec2).init(alloc);
    defer trails.deinit();
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        for (line) |c| {
            grid[pos.toIndex(h)] = c;
            if (c == '0') {
                try trails.append(pos);
            }
            pos.x += 1;
        }
        pos.y += 1;
        pos.x = 0;
    }

    var sum: i32 = 0;
    for (trails.items) |start| {
        const score = gatherTrailsInSet2(&grid, start, '0' - 1);
        sum += @intCast(score);
        // std.debug.print("start {any} => {any}\n", .{ start, score });
    }

    return sum;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
