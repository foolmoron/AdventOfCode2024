const std = @import("std");
const Regex = @import("regex").Regex;
const Captures = @import("regex").Captures;

const INPUT = @embedFile("./input.txt");

const Vec2 = struct {
    x: u64 = 0,
    y: u64 = 0,

    pub fn equals(self: @This(), other: Vec2) bool {
        return self.x == other.x and self.y == other.y;
    }
    pub fn add(self: @This(), vec: Vec2) Vec2 {
        return Vec2{ .x = self.x + vec.x, .y = self.y + vec.y };
    }
    pub fn multV(self: @This(), vec: Vec2) Vec2 {
        return Vec2{ .x = self.x * vec.x, .y = self.y * vec.y };
    }
    pub fn multS(self: @This(), scalar: u64) Vec2 {
        return Vec2{ .x = self.x * scalar, .y = self.y * scalar };
    }
};

const Game = struct {
    a: Vec2 = Vec2{},
    b: Vec2 = Vec2{},
    prize: Vec2 = Vec2{},
};

fn calc1(alloc: std.mem.Allocator) !u64 {
    var games = std.ArrayList(Game).init(alloc);
    defer games.deinit();

    var chunks = std.mem.tokenizeSequence(u8, INPUT, "\n\n");
    while (chunks.next()) |chunk| {
        var reButton = try Regex.compile(alloc, "X\\+(\\d+), Y\\+(\\d+)");
        defer reButton.deinit();
        var rePrize = try Regex.compile(alloc, "X=(\\d+), Y=(\\d+)");
        defer rePrize.deinit();

        var game = Game{};

        var lines = std.mem.tokenizeSequence(u8, chunk, "\n");
        const first = lines.next().?;
        if (try reButton.captures(first)) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            const x = try std.fmt.parseInt(u64, captures.sliceAt(1).?, 10);
            const y = try std.fmt.parseInt(u64, captures.sliceAt(2).?, 10);
            game.a.x = x;
            game.a.y = y;
        }
        const second = lines.next().?;
        if (try reButton.captures(second)) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            const x = try std.fmt.parseInt(u64, captures.sliceAt(1).?, 10);
            const y = try std.fmt.parseInt(u64, captures.sliceAt(2).?, 10);
            game.b.x = x;
            game.b.y = y;
        }
        const third = lines.next().?;
        if (try rePrize.captures(third)) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            const x = try std.fmt.parseInt(u64, captures.sliceAt(1).?, 10);
            const y = try std.fmt.parseInt(u64, captures.sliceAt(2).?, 10);
            game.prize.x = x;
            game.prize.y = y;
        }

        try games.append(game);
    }

    var sum: u64 = 0;
    for (games.items) |game| {
        var minCost: usize = std.math.maxInt(usize);
        var minCoords: Vec2 = Vec2{};
        for (0..100) |a| {
            for (0..100) |b| {
                var pos = game.a.multS(@intCast(a)).add(game.b.multS(@intCast(b)));
                if (pos.equals(game.prize)) {
                    const cost = a * 3 + b * 1;
                    if (cost < minCost) {
                        minCoords.x = @intCast(a);
                        minCoords.y = @intCast(b);
                        minCost = cost;
                    }
                }
            }
        }

        // std.debug.print("{any} => {any}\n", .{ minCoords, minCost });
        if (!minCoords.equals(Vec2{})) {
            sum += @intCast(minCost);
        }
    }

    return sum;
}

fn calc2(alloc: std.mem.Allocator) !u64 {
    var games = std.ArrayList(Game).init(alloc);
    defer games.deinit();

    var chunks = std.mem.tokenizeSequence(u8, INPUT, "\n\n");
    while (chunks.next()) |chunk| {
        var reButton = try Regex.compile(alloc, "X\\+(\\d+), Y\\+(\\d+)");
        defer reButton.deinit();
        var rePrize = try Regex.compile(alloc, "X=(\\d+), Y=(\\d+)");
        defer rePrize.deinit();

        var game = Game{};

        var lines = std.mem.tokenizeSequence(u8, chunk, "\n");
        const first = lines.next().?;
        if (try reButton.captures(first)) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            const x = try std.fmt.parseInt(u64, captures.sliceAt(1).?, 10);
            const y = try std.fmt.parseInt(u64, captures.sliceAt(2).?, 10);
            game.a.x = x;
            game.a.y = y;
        }
        const second = lines.next().?;
        if (try reButton.captures(second)) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            const x = try std.fmt.parseInt(u64, captures.sliceAt(1).?, 10);
            const y = try std.fmt.parseInt(u64, captures.sliceAt(2).?, 10);
            game.b.x = x;
            game.b.y = y;
        }
        const third = lines.next().?;
        if (try rePrize.captures(third)) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            const x = try std.fmt.parseInt(u64, captures.sliceAt(1).?, 10);
            const y = try std.fmt.parseInt(u64, captures.sliceAt(2).?, 10);
            game.prize.x = 10000000000000 + x;
            game.prize.y = 10000000000000 + y;
        }

        try games.append(game);
    }

    var sum: u64 = 0;
    for (games.items) |game| {
        const slopeX = -@as(f64, @floatFromInt(game.a.x)) / @as(f64, @floatFromInt(game.b.x));
        const interceptX = @as(f64, @floatFromInt(game.prize.x)) / @as(f64, @floatFromInt(game.b.x));
        const slopeY = -@as(f64, @floatFromInt(game.a.y)) / @as(f64, @floatFromInt(game.b.y));
        const interceptY = @as(f64, @floatFromInt(game.prize.y)) / @as(f64, @floatFromInt(game.b.y));
        const pointX = (interceptY - interceptX) / (slopeX - slopeY);
        const pointY = slopeX * pointX + interceptX;

        // std.debug.print("{any}\n", .{game});
        // std.debug.print("{any},{any}\n", .{ pointX, pointY });
        if (pointX < 0 or pointY < 0) {
            continue;
        }
        const intX: u64 = @intFromFloat(@round(pointX));
        const intY: u64 = @intFromFloat(@round(pointY));
        const cost = intX * 3 + intY * 1;

        const multX = intX * game.a.x + intY * game.b.x;
        const multY = intX * game.a.y + intY * game.b.y;
        if (multX != game.prize.x or multY != game.prize.y) {
            continue;
        }

        // std.debug.print("{any},{any} => {any},{any}\n", .{ intX, intY, pointX, pointY });
        // std.debug.print("{any},{any} => {any},{any} [{any}] => ${any}\n", .{ intX, intY, multX, multY, valid, cost });
        sum += @intCast(cost);
    }

    return sum;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
