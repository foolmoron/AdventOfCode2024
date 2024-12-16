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
    pub fn multV(self: @This(), vec: Vec2) Vec2 {
        return Vec2{ .x = self.x * vec.x, .y = self.y * vec.y };
    }
    pub fn multS(self: @This(), scalar: i32) Vec2 {
        return Vec2{ .x = self.x * scalar, .y = self.y * scalar };
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
    var iter = std.mem.tokenizeSequence(u8, INPUT, "\n\n");
    const grid = iter.next().?;
    var lines = std.mem.tokenizeAny(u8, grid, "\r\n");
    while (lines.next()) |_| {
        count += 1;
    }
    break :blk count;
};

fn calc1(alloc: std.mem.Allocator) !i32 {
    var iter = std.mem.tokenizeSequence(u8, INPUT, "\n\n");
    const gridString = iter.next().?;
    const dirString = iter.next().?;

    var grid: [w * h]u8 = undefined;
    var pos: Vec2 = undefined;
    for (0..h) |y| {
        @memcpy(grid[y * w .. (y + 1) * w], gridString[y * (w + 1) .. (y + 1) * (w + 1) - 1]); // skip \n
    }
    for (0..h) |y| {
        for (0..w) |x| {
            if (grid[y * w + x] == '@') {
                pos = Vec2{ .x = @intCast(x), .y = @intCast(y) };
            }
        }
    }

    var dirs = std.ArrayList(u8).init(alloc);
    defer dirs.deinit();
    for (dirString) |d| {
        if (d != '\n') {
            try dirs.append(d);
        }
    }

    const printGrid = struct {
        fn do(g: *[w * h]u8) void {
            for (0..h) |y| {
                for (0..w) |x| {
                    std.debug.print("{c}", .{g[y * w + x]});
                }
                std.debug.print("\n", .{});
            }
        }
    }.do;
    _ = printGrid; // autofix

    const tryMove = struct {
        fn do(g: *[w * h]u8, start: Vec2, dir: Vec2) bool {
            const next = start.add(dir);
            if (g[start.toIndex(w)] == '.') {
                return true;
            } else if (g[start.toIndex(w)] == '#') {
                return false;
            } else {
                const res = do(g, next, dir);
                if (res) {
                    g[next.toIndex(w)] = g[start.toIndex(w)];
                    g[start.toIndex(w)] = '.';
                }
                return res;
            }
        }
    }.do;

    for (dirs.items) |d| {
        const dir = switch (d) {
            '^' => Vec2{ .x = 0, .y = -1 },
            'v' => Vec2{ .x = 0, .y = 1 },
            '<' => Vec2{ .x = -1, .y = 0 },
            '>' => Vec2{ .x = 1, .y = 0 },
            else => Vec2{ .x = 0, .y = 0 },
        };
        if (tryMove(&grid, pos, dir) and grid[pos.add(dir).toIndex(w)] == '@') {
            pos = pos.add(dir);
        }
        // printGrid(&grid);
    }

    var sum: usize = 0;
    for (0..h) |y| {
        for (0..w) |x| {
            if (grid[y * w + x] == 'O') {
                sum += y * 100 + x;
            }
        }
    }

    return @intCast(sum);
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var iter = std.mem.tokenizeSequence(u8, INPUT, "\n\n");
    const gridString = iter.next().?;
    const dirString = iter.next().?;

    var grid: [w * 2 * h]u8 = undefined;
    var pos: Vec2 = undefined;
    for (0..h) |y| {
        for (0..w) |x| {
            const char = gridString[y * (w + 1) + x];
            if (char == '@') {
                grid[y * w * 2 + x * 2] = '@';
                grid[y * w * 2 + x * 2 + 1] = '.';
            } else if (char == 'O') {
                grid[y * w * 2 + x * 2] = '[';
                grid[y * w * 2 + x * 2 + 1] = ']';
            } else {
                grid[y * w * 2 + x * 2] = char;
                grid[y * w * 2 + x * 2 + 1] = char;
            }
        }
    }
    for (0..h) |y| {
        for (0..w) |x| {
            if (grid[y * w * 2 + x * 2] == '@') {
                pos = Vec2{ .x = @intCast(x * 2), .y = @intCast(y) };
            }
        }
    }

    var dirs = std.ArrayList(u8).init(alloc);
    defer dirs.deinit();
    for (dirString) |d| {
        if (d != '\n') {
            try dirs.append(d);
        }
    }

    const printGrid = struct {
        fn do(g: *[w * 2 * h]u8) void {
            for (0..h) |y| {
                for (0..w) |x| {
                    std.debug.print("{c}", .{g[y * w * 2 + x * 2]});
                    std.debug.print("{c}", .{g[y * w * 2 + x * 2 + 1]});
                }
                std.debug.print("\n", .{});
            }
        }
    }.do;
    _ = printGrid; // autofix

    const testMove = struct {
        fn do(g: *[w * 2 * h]u8, start: Vec2, dir: Vec2) bool {
            const next = start.add(dir);
            if (g[start.toIndex(w * 2)] == '.') {
                return true;
            } else if (g[start.toIndex(w * 2)] == '#') {
                return false;
            } else if (g[start.toIndex(w * 2)] == '[' and dir.y != 0) {
                const res1 = do(g, next, dir);
                const res2 = do(g, next.add(Vec2{ .x = 1 }), dir);
                return res1 and res2;
            } else if (g[start.toIndex(w * 2)] == ']' and dir.y != 0) {
                const res1 = do(g, next, dir);
                const res2 = do(g, next.add(Vec2{ .x = -1 }), dir);
                return res1 and res2;
            } else {
                const res = do(g, next, dir);
                return res;
            }
        }
    }.do;

    const doMove = struct {
        fn do(g: *[w * 2 * h]u8, start: Vec2, dir: Vec2) void {
            const next = start.add(dir);
            if (g[start.toIndex(w * 2)] == '.') {
                return;
            } else if (g[start.toIndex(w * 2)] == '#') {
                return;
            } else if (g[start.toIndex(w * 2)] == '[' and dir.y != 0) {
                do(g, next, dir);
                do(g, next.add(Vec2{ .x = 1 }), dir);
                g[next.toIndex(w * 2)] = g[start.toIndex(w * 2)];
                g[start.toIndex(w * 2)] = '.';
                g[next.add(Vec2{ .x = 1 }).toIndex(w * 2)] = g[start.add(Vec2{ .x = 1 }).toIndex(w * 2)];
                g[start.add(Vec2{ .x = 1 }).toIndex(w * 2)] = '.';
                return;
            } else if (g[start.toIndex(w * 2)] == ']' and dir.y != 0) {
                do(g, next, dir);
                do(g, next.add(Vec2{ .x = -1 }), dir);
                g[next.toIndex(w * 2)] = g[start.toIndex(w * 2)];
                g[start.toIndex(w * 2)] = '.';
                g[next.add(Vec2{ .x = -1 }).toIndex(w * 2)] = g[start.add(Vec2{ .x = -1 }).toIndex(w * 2)];
                g[start.add(Vec2{ .x = -1 }).toIndex(w * 2)] = '.';
                return;
            } else {
                do(g, next, dir);
                g[next.toIndex(w * 2)] = g[start.toIndex(w * 2)];
                g[start.toIndex(w * 2)] = '.';
            }
        }
    }.do;

    for (dirs.items) |d| {
        const dir = switch (d) {
            '^' => Vec2{ .x = 0, .y = -1 },
            'v' => Vec2{ .x = 0, .y = 1 },
            '<' => Vec2{ .x = -1, .y = 0 },
            '>' => Vec2{ .x = 1, .y = 0 },
            else => Vec2{ .x = 0, .y = 0 },
        };
        const canMove = testMove(&grid, pos, dir);
        if (canMove) {
            doMove(&grid, pos, dir);
        }
        if (canMove and grid[pos.add(dir).toIndex(w * 2)] == '@') {
            pos = pos.add(dir);
        }
        // std.debug.print("\n{c} : {any}\n", .{ d, canMove });
        // printGrid(&grid);
    }

    var sum: usize = 0;
    for (0..h) |y| {
        for (0..w * 2) |x2| {
            if (grid[y * w * 2 + x2] == '[') {
                sum += y * 100 + x2;
            }
        }
    }

    return @intCast(sum);
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
