const std = @import("std");
const Regex = @import("regex").Regex;
const Captures = @import("regex").Captures;

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

const Bot = struct {
    pos: Vec2 = Vec2{},
    vel: Vec2 = Vec2{},
};

fn calc1(alloc: std.mem.Allocator) !i32 {
    var bots = std.ArrayList(Bot).init(alloc);
    defer bots.deinit();

    var lines = std.mem.tokenizeSequence(u8, INPUT, "\n");
    while (lines.next()) |line| {
        var re = try Regex.compile(alloc, "p=([\\d-]+),([\\d-]+) v=([\\d-]+),([\\d-]+)");
        defer re.deinit();

        var bot = Bot{};

        if (try re.captures(line)) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            bot.pos.x = try std.fmt.parseInt(i32, captures.sliceAt(1).?, 10);
            bot.pos.y = try std.fmt.parseInt(i32, captures.sliceAt(2).?, 10);
            bot.vel.x = try std.fmt.parseInt(i32, captures.sliceAt(3).?, 10);
            bot.vel.y = try std.fmt.parseInt(i32, captures.sliceAt(4).?, 10);
        }

        try bots.append(bot);
    }

    const steps = 100;
    const w = 101;
    const h = 103;
    var grid: [w * h]i32 = undefined;
    @memset(&grid, 0);
    for (bots.items) |*bot| {
        bot.pos.x = @mod(bot.pos.x + (steps * bot.vel.x), w);
        bot.pos.y = @mod(bot.pos.y + (steps * bot.vel.y), h);
        grid[bot.pos.toIndex(w)] += 1;
    }

    var quad1: i32 = 0;
    for (0..w / 2) |x| {
        for (0..h / 2) |y| {
            quad1 += grid[y * w + x];
        }
    }
    var quad2: i32 = 0;
    for (w / 2 + 1..w) |x| {
        for (0..h / 2) |y| {
            quad2 += grid[y * w + x];
        }
    }
    var quad3: i32 = 0;
    for (0..w / 2) |x| {
        for (h / 2 + 1..h) |y| {
            quad3 += grid[y * w + x];
        }
    }
    var quad4: i32 = 0;
    for (w / 2 + 1..w) |x| {
        for (h / 2 + 1..h) |y| {
            quad4 += grid[y * w + x];
        }
    }
    // std.debug.print("{any} {any} {any} {any}\n", .{ quad1, quad2, quad3, quad4 });
    const sum = quad1 * quad2 * quad3 * quad4;

    return sum;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    const stdout = std.io.getStdOut().writer();
    _ = stdout; // autofix
    var bots = std.ArrayList(Bot).init(alloc);
    defer bots.deinit();

    var lines = std.mem.tokenizeSequence(u8, INPUT, "\n");
    while (lines.next()) |line| {
        var re = try Regex.compile(alloc, "p=([\\d-]+),([\\d-]+) v=([\\d-]+),([\\d-]+)");
        defer re.deinit();

        var bot = Bot{};

        if (try re.captures(line)) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            bot.pos.x = try std.fmt.parseInt(i32, captures.sliceAt(1).?, 10);
            bot.pos.y = try std.fmt.parseInt(i32, captures.sliceAt(2).?, 10);
            bot.vel.x = try std.fmt.parseInt(i32, captures.sliceAt(3).?, 10);
            bot.vel.y = try std.fmt.parseInt(i32, captures.sliceAt(4).?, 10);
        }

        try bots.append(bot);
    }

    const w = 101;
    const h = 103;
    const numSteps = 50000;
    const jumpSteps = 1;
    var grid: [w * h]bool = undefined;
    var minSteps: i32 = 0;
    var minVariance: i32 = std.math.maxInt(i32);
    for (1..numSteps) |s| {
        @memset(&grid, false);
        for (bots.items) |*bot| {
            bot.pos.x = @mod(bot.pos.x + (jumpSteps * bot.vel.x), w);
            bot.pos.y = @mod(bot.pos.y + (jumpSteps * bot.vel.y), h);
            grid[bot.pos.toIndex(w)] = true;
        }
        var variance: i32 = 0;
        for (bots.items) |*bot| {
            variance += (bot.pos.x - w / 2) * (bot.pos.x - w / 2) + (bot.pos.y - h / 2) * (bot.pos.y - h / 2);
        }
        if (variance < minVariance) {
            minVariance = variance;
            minSteps = @intCast(s);
            // try stdout.print("\n\n{any} ({any}):\n", .{ s, variance });
            // for (0..h) |y| {
            //     for (0..w) |x| {
            //         const char: u8 = if (grid[y * w + x]) 'O' else '.';
            //         try stdout.print("{c}", .{char});
            //     }
            //     try stdout.print("\n", .{});
            // }
        }
    }

    return minSteps;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
