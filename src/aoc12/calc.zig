const std = @import("std");

const INPUT = @embedFile("./input.txt");

const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn toIndex(self: @This(), height: usize) usize {
        return @intCast(@as(i32, @intCast(height)) * self.y + self.x);
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

const GardenKey = struct {
    char: u8,
    start: Vec2,
};

fn doDFS(start: Vec2, grid: *[w * h]u8, list: *std.ArrayList(Vec2), alreadySeen: *std.AutoHashMap(Vec2, void)) !void {
    try alreadySeen.put(start, {});
    try list.append(start);

    const char = grid[start.toIndex(h)];
    for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
        const startNext = Vec2{ .x = start.x + dir.x, .y = start.y + dir.y };
        if (startNext.x < 0 or startNext.x >= w or startNext.y < 0 or startNext.y >= h) {
            continue;
        }
        if (alreadySeen.contains(startNext)) {
            continue;
        }
        if (grid[startNext.toIndex(h)] != char) {
            continue;
        }
        try doDFS(startNext, grid, list, alreadySeen);
    }
}

fn calc1(alloc: std.mem.Allocator) !i32 {
    var gardens = std.AutoHashMap(GardenKey, std.ArrayList(Vec2)).init(alloc);
    defer gardens.deinit();
    defer {
        var values = gardens.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
    }

    var grid: [w * h]u8 = undefined;

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    var pos = Vec2{};
    while (lines.next()) |line| {
        for (line) |c| {
            grid[pos.toIndex(h)] = c;
            pos.x += 1;
        }
        pos.x = 0;
        pos.y += 1;
    }

    var alreadySeen = std.AutoHashMap(Vec2, void).init(alloc);
    defer alreadySeen.deinit();
    for (0..h) |y| {
        for (0..w) |x| {
            const start = Vec2{ .x = @intCast(x), .y = @intCast(y) };
            if (alreadySeen.contains(start)) {
                continue;
            }
            var list = std.ArrayList(Vec2).init(alloc);
            try doDFS(start, &grid, &list, &alreadySeen);
            try gardens.put(GardenKey{ .char = grid[start.toIndex(h)], .start = start }, list);
        }
    }

    var sum: i32 = 0;
    var iter = gardens.iterator();
    while (iter.next()) |pair| {
        const char = pair.key_ptr.*.char;
        _ = char; // autofix
        const start = pair.key_ptr.*.start;
        _ = start; // autofix
        const area = pair.value_ptr.items.len;
        var perimeter: usize = 0;
        for (pair.value_ptr.items) |p| {
            for ([_]Vec2{ .{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 } }) |dir| {
                const posToTest = Vec2{ .x = p.x + dir.x, .y = p.y + dir.y };
                var contains = false;
                for (pair.value_ptr.items) |p2| {
                    if (posToTest.x == p2.x and posToTest.y == p2.y) {
                        contains = true;
                        break;
                    }
                }
                if (!contains) {
                    perimeter += 1;
                }
            }
        }
        sum += @intCast(area * perimeter);
        // std.debug.print("{c}[{any},{any}] a {any}, p {any}\n", .{ char, start.x, start.y, area, perimeter });
    }

    return sum;
}

const DIR = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

const Wall = struct {
    pos: Vec2,
    dir: DIR,
};

fn calc2(alloc: std.mem.Allocator) !i32 {
    var gardens = std.AutoHashMap(GardenKey, std.ArrayList(Vec2)).init(alloc);
    defer gardens.deinit();
    defer {
        var values = gardens.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
    }

    var grid: [w * h]u8 = undefined;

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    var pos = Vec2{};
    while (lines.next()) |line| {
        for (line) |c| {
            grid[pos.toIndex(h)] = c;
            pos.x += 1;
        }
        pos.x = 0;
        pos.y += 1;
    }

    var alreadySeen = std.AutoHashMap(Vec2, void).init(alloc);
    defer alreadySeen.deinit();
    for (0..h) |y| {
        for (0..w) |x| {
            const start = Vec2{ .x = @intCast(x), .y = @intCast(y) };
            if (alreadySeen.contains(start)) {
                continue;
            }
            var list = std.ArrayList(Vec2).init(alloc);
            try doDFS(start, &grid, &list, &alreadySeen);
            try gardens.put(GardenKey{ .char = grid[start.toIndex(h)], .start = start }, list);
        }
    }

    var sum: i32 = 0;
    var iter = gardens.iterator();
    while (iter.next()) |pair| {
        const char = pair.key_ptr.*.char;
        const start = pair.key_ptr.*.start;
        _ = start; // autofix
        const area = pair.value_ptr.items.len;
        var wallCount: usize = 0;

        var walls = std.AutoHashMap(Wall, void).init(alloc);
        defer walls.deinit();
        for (pair.value_ptr.items) |p| {
            for ([_]DIR{ DIR.UP, DIR.DOWN, DIR.LEFT, DIR.RIGHT }) |d| {
                var dir = Vec2{};
                if (d == DIR.UP) {
                    dir = Vec2{ .x = 0, .y = -1 };
                } else if (d == DIR.DOWN) {
                    dir = Vec2{ .x = 0, .y = 1 };
                } else if (d == DIR.LEFT) {
                    dir = Vec2{ .x = -1, .y = 0 };
                } else if (d == DIR.RIGHT) {
                    dir = Vec2{ .x = 1, .y = 0 };
                }

                const posToTest = Vec2{ .x = p.x + dir.x, .y = p.y + dir.y };

                if (posToTest.x >= 0 and posToTest.x < w and posToTest.y >= 0 and posToTest.y < h and grid[posToTest.toIndex(h)] == char) {
                    continue;
                }

                try walls.put(Wall{ .pos = posToTest, .dir = d }, {});
            }
        }

        var wallsSeen = std.AutoHashMap(Wall, void).init(alloc);
        defer wallsSeen.deinit();
        var wallsIter = walls.iterator();
        while (wallsIter.next()) |wall| {
            const d = wall.key_ptr.dir;
            const posToTest = wall.key_ptr.pos;

            const wallIsUnique = !wallsSeen.contains(wall.key_ptr.*);
            if (wallIsUnique) {
                wallCount += 1;
            }
            try wallsSeen.put(wall.key_ptr.*, {});
            if (d == DIR.UP or d == DIR.DOWN) {
                for (1..w) |x| {
                    var posSeen = posToTest;
                    posSeen.x += @intCast(x);
                    if (!walls.contains(Wall{ .dir = d, .pos = posSeen })) {
                        break;
                    }
                    try wallsSeen.put(Wall{ .dir = d, .pos = posSeen }, {});
                }
                for (1..w) |x| {
                    var posSeen = posToTest;
                    posSeen.x -= @intCast(x);
                    if (!walls.contains(Wall{ .dir = d, .pos = posSeen })) {
                        break;
                    }
                    try wallsSeen.put(Wall{ .dir = d, .pos = posSeen }, {});
                }
            } else if (d == DIR.LEFT or d == DIR.RIGHT) {
                for (1..h) |y| {
                    var posSeen = posToTest;
                    posSeen.y += @intCast(y);
                    if (!walls.contains(Wall{ .dir = d, .pos = posSeen })) {
                        break;
                    }
                    try wallsSeen.put(Wall{ .dir = d, .pos = posSeen }, {});
                }
                for (1..h) |y| {
                    var posSeen = posToTest;
                    posSeen.y -= @intCast(y);
                    if (!walls.contains(Wall{ .dir = d, .pos = posSeen })) {
                        break;
                    }
                    try wallsSeen.put(Wall{ .dir = d, .pos = posSeen }, {});
                }
            }
        }
        sum += @intCast(area * wallCount);
        // std.debug.print("{c}[{any},{any}] a {any}, p {any}\n", .{ char, start.x, start.y, area, perimeter });
    }

    return sum;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
