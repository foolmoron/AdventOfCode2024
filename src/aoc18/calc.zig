const std = @import("std");

const INPUT = @embedFile("./input.txt");
const s = 71;
const n = 1024;

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

const Node1 = struct {
    pos: Vec2,
    dist: i32,

    fn order(_: void, a: Node1, b: Node1) std.math.Order {
        return std.math.order(a.dist, b.dist);
    }
};

fn calc1(alloc: std.mem.Allocator) !i32 {
    var grid: [s * s]u8 = undefined;
    @memset(&grid, '.');
    var bytes = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    for (0..n) |_| {
        const line = bytes.next().?;
        var split = std.mem.tokenizeAny(u8, line, ",");
        const x = try std.fmt.parseInt(usize, split.next().?, 10);
        const y = try std.fmt.parseInt(usize, split.next().?, 10);
        grid[y * s + x] = '#';
    }

    // for (0..s) |y| {
    //     for (0..s) |x| {
    //         std.debug.print("{c}", .{grid[y * s + x]});
    //     }
    //     std.debug.print("\n", .{});
    // }

    var alreadySeen = std.AutoHashMap(Vec2, i32).init(alloc);
    defer alreadySeen.deinit();
    var q = std.PriorityQueue(Node1, void, Node1.order).init(alloc, {});
    defer q.deinit();
    try q.add(Node1{ .pos = Vec2{}, .dist = 0 });

    var finalNode = Node1{ .pos = Vec2{}, .dist = std.math.maxInt(i32) };
    while (q.items.len > 0) {
        const node = q.remove();

        if (node.dist >= alreadySeen.get(node.pos) orelse std.math.maxInt(i32)) {
            continue;
        }

        if (node.pos.x == s - 1 and node.pos.y == s - 1 and node.dist < finalNode.dist) {
            finalNode = node;
        }

        try alreadySeen.put(node.pos, node.dist);

        for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
            const posNext = node.pos.add(dir);
            if (posNext.x < 0 or posNext.x >= s or posNext.y < 0 or posNext.y >= s) {
                continue;
            }
            if (grid[posNext.toIndex(s)] == '#') {
                continue;
            }
            const next = Node1{ .pos = posNext, .dist = node.dist + 1 };
            try q.add(next);
        }
    }

    return finalNode.dist;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var grid: [s * s]u8 = undefined;
    @memset(&grid, '.');
    var bytes = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    var i: usize = 0;
    var coord = Vec2{};
    while (bytes.next()) |line| {
        var split = std.mem.tokenizeAny(u8, line, ",");
        const x = try std.fmt.parseInt(usize, split.next().?, 10);
        const y = try std.fmt.parseInt(usize, split.next().?, 10);
        grid[y * s + x] = '#';
        i += 1;
        if (i <= n) {
            continue;
        }

        var alreadySeen = std.AutoHashMap(Vec2, i32).init(alloc);
        defer alreadySeen.deinit();
        var q = std.PriorityQueue(Node1, void, Node1.order).init(alloc, {});
        defer q.deinit();
        try q.add(Node1{ .pos = Vec2{}, .dist = 0 });

        var finalNode = Node1{ .pos = Vec2{}, .dist = std.math.maxInt(i32) };
        while (q.items.len > 0) {
            const node = q.remove();

            if (node.dist >= alreadySeen.get(node.pos) orelse std.math.maxInt(i32)) {
                continue;
            }

            if (node.pos.x == s - 1 and node.pos.y == s - 1 and node.dist < finalNode.dist) {
                finalNode = node;
            }

            try alreadySeen.put(node.pos, node.dist);

            for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
                const posNext = node.pos.add(dir);
                if (posNext.x < 0 or posNext.x >= s or posNext.y < 0 or posNext.y >= s) {
                    continue;
                }
                if (grid[posNext.toIndex(s)] == '#') {
                    continue;
                }
                const next = Node1{ .pos = posNext, .dist = node.dist + 1 };
                try q.add(next);
            }
        }

        if (finalNode.dist != std.math.maxInt(i32)) {
            continue;
        }

        coord.x = @intCast(x);
        coord.y = @intCast(y);
        break;
    }

    std.debug.print("{any},{any}\n", .{ coord.x, coord.y });
    return 1;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
