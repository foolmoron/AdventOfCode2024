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

const Node1 = struct {
    pos: Vec2,
    dist: i32,

    fn order(_: void, a: Node1, b: Node1) std.math.Order {
        return std.math.order(a.dist, b.dist);
    }
};

const Vec2Vec2 = struct {
    a: Vec2,
    b: Vec2,
};

fn calc1(alloc: std.mem.Allocator) !i32 {
    var grid: [w * h]u8 = undefined;

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    var pos = Vec2{};
    var start = Vec2{};
    var end = Vec2{};
    while (lines.next()) |line| {
        for (line) |c| {
            if (c == 'S') {
                start = pos;
            } else if (c == 'E') {
                end = pos;
            }
            grid[pos.toIndex(w)] = c;
            pos.x += 1;
        }
        pos.x = 0;
        pos.y += 1;
    }

    // first solve
    var bestDist: i32 = 9999999;
    {
        var alreadySeen = std.AutoHashMap(Vec2, i32).init(alloc);
        defer alreadySeen.deinit();
        var q = std.PriorityQueue(Node1, void, Node1.order).init(alloc, {});
        defer q.deinit();
        try q.add(Node1{ .pos = start, .dist = 0 });

        var finalNode = Node1{ .pos = Vec2{}, .dist = std.math.maxInt(i32) };
        while (q.items.len > 0) {
            const node = q.remove();

            if (node.dist >= alreadySeen.get(node.pos) orelse std.math.maxInt(i32)) {
                continue;
            }

            if (node.pos.equals(end) and node.dist < finalNode.dist) {
                finalNode = node;
            }

            try alreadySeen.put(node.pos, node.dist);

            for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
                const posNext = node.pos.add(dir);
                if (grid[posNext.toIndex(w)] == '#') {
                    continue;
                }
                const next = Node1{ .pos = posNext, .dist = node.dist + 1 };
                try q.add(next);
            }
        }

        bestDist = finalNode.dist;
    }

    var validCheats = std.AutoHashMap(Vec2Vec2, void).init(alloc);
    defer validCheats.deinit();
    for (1..h - 1) |y| {
        for (1..w - 1) |x| {
            for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dirCheat| {
                var posCheat = Vec2{ .x = @intCast(x), .y = @intCast(y) };
                var posCheatEnd = posCheat.add(dirCheat);
                if (grid[posCheat.toIndex(w)] != '#' or grid[posCheatEnd.toIndex(w)] != '.') {
                    continue;
                }
                grid[posCheat.toIndex(w)] = '.';
                defer grid[posCheat.toIndex(w)] = '#';

                var alreadySeen = std.AutoHashMap(Vec2, i32).init(alloc);
                defer alreadySeen.deinit();
                var q = std.PriorityQueue(Node1, void, Node1.order).init(alloc, {});
                defer q.deinit();
                try q.add(Node1{ .pos = start, .dist = 0 });

                var finalNode = Node1{ .pos = Vec2{}, .dist = std.math.maxInt(i32) };
                while (q.items.len > 0) {
                    const node = q.remove();

                    if (node.dist >= alreadySeen.get(node.pos) orelse std.math.maxInt(i32)) {
                        continue;
                    }

                    if (node.pos.equals(end) and node.dist < finalNode.dist) {
                        finalNode = node;
                    }

                    try alreadySeen.put(node.pos, node.dist);

                    for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
                        const posNext = node.pos.add(dir);
                        if (grid[posNext.toIndex(w)] == '#') {
                            continue;
                        }
                        const next = Node1{ .pos = posNext, .dist = node.dist + 1 };
                        try q.add(next);
                    }
                }

                const distDiff = bestDist - finalNode.dist;
                if (distDiff >= 100) {
                    const res = try validCheats.getOrPut(Vec2Vec2{ .a = posCheat, .b = posCheat });
                    if (!res.found_existing) {
                        std.debug.print("start: {any} end: {any} distDiff: {d}\n", .{ posCheat, posCheatEnd, distDiff });
                    }
                }
            }
        }
    }

    return @intCast(validCheats.count());
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    _ = alloc; // autofix
    return 0;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
