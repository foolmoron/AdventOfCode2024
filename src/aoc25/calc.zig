const std = @import("std");

const INPUT = @embedFile("./input.txt");
const w = 5;
const h = 7;

fn calc1(alloc: std.mem.Allocator) !i32 {
    var locks = std.ArrayList([w]u8).init(alloc);
    defer locks.deinit();
    var keys = std.ArrayList([w]u8).init(alloc);
    defer keys.deinit();

    var chunks = std.mem.tokenizeSequence(u8, INPUT, "\n\n");
    while (chunks.next()) |chunk| {
        var grid: [w * h]u1 = undefined;
        var heights: [w]u8 = undefined;
        @memset(&heights, 0);
        var lines = std.mem.tokenizeAny(u8, chunk, "\r\n");
        var i: usize = 0;
        var isLock = false;
        while (lines.next()) |line| {
            if (i == 0) {
                isLock = line[0] == '#';
            }
            for (line) |c| {
                grid[i] = if (c == '#') 1 else 0;
                i += 1;
            }
        }
        for (0..w) |x| {
            for (0..h) |y| {
                heights[x] += grid[y * w + x];
            }
        }
        if (isLock) {
            try locks.append(heights);
        } else {
            try keys.append(heights);
        }
    }

    var count: i32 = 0;
    var a: usize = 0;
    var b: usize = 0;
    for (locks.items) |lock| {
        a += 1;
        for (keys.items) |key| {
            b += 1;
            // std.debug.print("{any} x {any}", .{ lock, key });
            var valid = true;
            for (0..w) |i| {
                valid = valid and (lock[i] + key[i] <= h);
            }
            if (valid) {
                count += 1;
                // std.debug.print(" good\n", .{});
            } else {
                // std.debug.print(" bad\n", .{});
            }
        }
    }

    return count;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    _ = alloc; // autofix
    return 0;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
