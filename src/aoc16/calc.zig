const std = @import("std");

const INPUT = @embedFile("./input.txt");

const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn toIndex(self: @This(), width: usize) usize {
        return @intCast(@as(i32, @intCast(width)) * self.y + self.x);
    }
    pub fn equals(self: @This(), other: Vec2) bool {
        return self.x == other.x and self.y == other.y;
    }
    pub fn add(self: @This(), vec: Vec2) Vec2 {
        return Vec2{ .x = self.x + vec.x, .y = self.y + vec.y };
    }
};
const w = blk: {
    var iter = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    const line = iter.next().?;
    break :blk line.len;
};
const h = blk: {
    @setEvalBranchQuota(100000);
    var count: usize = 0;
    var iter = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (iter.next()) |_| {
        count += 1;
    }
    break :blk count;
};

const PosDir = struct {
    pos: Vec2,
    dir: Vec2,
};
const Node1 = struct {
    posdir: PosDir,
    score: i32,
};

fn calc1(alloc: std.mem.Allocator) !i32 {
    var grid: [w * h]u8 = undefined;

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    var pos = Vec2{};
    var start = Vec2{};
    while (lines.next()) |line| {
        for (line) |c| {
            if (c == 'S') {
                start = pos;
            }
            grid[pos.toIndex(w)] = c;
            pos.x += 1;
        }
        pos.x = 0;
        pos.y += 1;
    }

    var alreadySeen = std.AutoHashMap(PosDir, i32).init(alloc);
    defer alreadySeen.deinit();
    var q = std.ArrayList(Node1).init(alloc);
    defer q.deinit();
    try q.append(Node1{ .posdir = PosDir{ .pos = start, .dir = Vec2{ .x = 1, .y = 0 } }, .score = 0 });

    var finalNode: Node1 = Node1{ .posdir = PosDir{ .pos = Vec2{}, .dir = Vec2{} }, .score = std.math.maxInt(i32) };
    while (q.items.len > 0) {
        var node = q.orderedRemove(0);

        if (node.score >= alreadySeen.get(node.posdir) orelse std.math.maxInt(i32)) {
            continue;
        }

        if (grid[node.posdir.pos.toIndex(w)] == 'E' and node.score < finalNode.score) {
            finalNode = node;
        }

        try alreadySeen.put(node.posdir, node.score);
        for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
            if (node.posdir.dir.x == -dir.x and node.posdir.dir.y == -dir.y) {
                continue;
            }
            const posNext = node.posdir.pos.add(dir);
            if (grid[posNext.toIndex(w)] == '#') {
                continue;
            }
            const scoreAdd: i32 = if (node.posdir.dir.equals(dir)) 1 else 1001;
            const next = Node1{ .posdir = PosDir{ .pos = posNext, .dir = dir }, .score = node.score + scoreAdd };
            try q.append(next);
        }
    }

    return finalNode.score;
}

const Node2 = struct {
    posdir: PosDir,
    score: i32,
    path: std.ArrayList(Vec2),
};

fn calc2(alloc: std.mem.Allocator) !i32 {
    var grid: [w * h]u8 = undefined;

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    var pos = Vec2{};
    var start = Vec2{};
    while (lines.next()) |line| {
        for (line) |c| {
            if (c == 'S') {
                start = pos;
            }
            grid[pos.toIndex(w)] = c;
            pos.x += 1;
        }
        pos.x = 0;
        pos.y += 1;
    }

    var alreadySeen = std.AutoHashMap(PosDir, i32).init(alloc);
    defer alreadySeen.deinit();
    var q = std.ArrayList(Node2).init(alloc);
    defer q.deinit();
    try q.append(Node2{ .posdir = PosDir{ .pos = start, .dir = Vec2{ .x = 1, .y = 0 } }, .score = 0, .path = std.ArrayList(Vec2).init(alloc) });

    var bestPathPositions = std.AutoHashMap(Vec2, void).init(alloc);
    defer bestPathPositions.deinit();

    var finalNode: Node2 = Node2{ .posdir = PosDir{ .pos = Vec2{}, .dir = Vec2{} }, .score = std.math.maxInt(i32), .path = undefined };
    while (q.items.len > 0) {
        var node = q.orderedRemove(0);
        defer node.path.deinit();
        try node.path.append(node.posdir.pos);

        if (node.score > alreadySeen.get(node.posdir) orelse std.math.maxInt(i32)) {
            continue;
        }

        if (grid[node.posdir.pos.toIndex(w)] == 'E') {
            if (node.score < finalNode.score) {
                finalNode = node;
                bestPathPositions.clearRetainingCapacity();
            }
            if (node.score <= finalNode.score) {
                for (node.path.items) |p| {
                    try bestPathPositions.put(p, {});
                }
            }
        }

        try alreadySeen.put(node.posdir, node.score);
        for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
            if (node.posdir.dir.x == -dir.x and node.posdir.dir.y == -dir.y) {
                continue;
            }
            const posNext = node.posdir.pos.add(dir);
            if (grid[posNext.toIndex(w)] == '#') {
                continue;
            }
            const scoreAdd: i32 = if (node.posdir.dir.equals(dir)) 1 else 1001;
            const next = Node2{ .posdir = PosDir{ .pos = posNext, .dir = dir }, .score = node.score + scoreAdd, .path = try node.path.clone() };
            try q.append(next);
        }
    }

    return @intCast(bestPathPositions.count());
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
