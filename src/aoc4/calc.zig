const std = @import("std");

const INPUT = @embedFile("./input.txt");

const seq1 = "XMAS";
fn search1(grid: std.ArrayList([]const u8), x: usize, y: usize, dir: [2]i32) bool {
    var s: usize = 0;
    for (seq1, 0..) |c, i| {
        const x2: i32 = @as(i32, @intCast(x)) + dir[0] * @as(i32, @intCast(i));
        const y2: i32 = @as(i32, @intCast(y)) + dir[1] * @as(i32, @intCast(i));
        if (y2 >= 0 and y2 < grid.items.len and x2 >= 0 and x2 < grid.items[@intCast(y2)].len and grid.items[@intCast(y2)][@intCast(x2)] == c) {
            s += 1;
            if (s == seq1.len) {
                return true;
            }
        } else {
            break;
        }
    }
    return false;
}

fn calc1(alloc: std.mem.Allocator) !i32 {
    var grid = std.ArrayList([]const u8).init(alloc);
    defer grid.deinit();

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        try grid.append(line);
    }

    const dirs = [_][2]i32{
        .{ 1, 0 },
        .{ -1, 0 },
        .{ 0, 1 },
        .{ 0, -1 },
        .{ 1, 1 },
        .{ -1, 1 },
        .{ 1, -1 },
        .{ -1, -1 },
    };
    var count: i32 = 0;
    for (0..grid.items.len) |y| {
        for (0..grid.items[y].len) |x| {
            for (dirs) |dir| {
                if (search1(grid, x, y, dir)) {
                    count += 1;
                }
            }
        }
    }

    return count;
}

fn search2(grid: std.ArrayList([]const u8), x: usize, y: usize, starts: [2][2]i32) bool {
    if (grid.items[y][x] != 'A') {
        return false;
    }
    const x1m: i32 = @as(i32, @intCast(x)) + starts[0][0];
    const y1m: i32 = @as(i32, @intCast(y)) + starts[0][1];
    const x1s: i32 = @as(i32, @intCast(x)) - starts[0][0];
    const y1s: i32 = @as(i32, @intCast(y)) - starts[0][1];
    const x2m: i32 = @as(i32, @intCast(x)) + starts[1][0];
    const y2m: i32 = @as(i32, @intCast(y)) + starts[1][1];
    const x2s: i32 = @as(i32, @intCast(x)) - starts[1][0];
    const y2s: i32 = @as(i32, @intCast(y)) - starts[1][1];
    if (y1m >= 0 and y1m < grid.items.len and x1m >= 0 and x1m < grid.items[@intCast(y1m)].len and grid.items[@intCast(y1m)][@intCast(x1m)] == 'M' and
        y1s >= 0 and y1s < grid.items.len and x1s >= 0 and x1s < grid.items[@intCast(y1s)].len and grid.items[@intCast(y1s)][@intCast(x1s)] == 'S' and
        y2m >= 0 and y2m < grid.items.len and x2m >= 0 and x2m < grid.items[@intCast(y2m)].len and grid.items[@intCast(y2m)][@intCast(x2m)] == 'M' and
        y2s >= 0 and y2s < grid.items.len and x2s >= 0 and x2s < grid.items[@intCast(y2s)].len and grid.items[@intCast(y2s)][@intCast(x2s)] == 'S')
    {
        return true;
    }
    return false;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var grid = std.ArrayList([]const u8).init(alloc);
    defer grid.deinit();

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        try grid.append(line);
    }

    const starts = [_][2][2]i32{
        .{ .{ -1, 1 }, .{ 1, 1 } },
        .{ .{ 1, 1 }, .{ 1, -1 } },
        .{ .{ 1, -1 }, .{ -1, -1 } },
        .{ .{ -1, -1 }, .{ -1, 1 } },
    };
    var count: i32 = 0;
    for (0..grid.items.len) |y| {
        for (0..grid.items[y].len) |x| {
            for (starts) |start| {
                if (search2(grid, x, y, start)) {
                    count += 1;
                }
            }
        }
    }

    return count;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
