const std = @import("std");

const INPUT = @embedFile("./input.txt");
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

const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn toIndex(self: @This(), width: usize) usize {
        return @intCast(@as(i32, @intCast(width)) * self.y + self.x);
    }
    pub fn inBounds(self: @This(), width: i32, height: i32) bool {
        return self.x >= 0 and self.x < width and self.y >= 0 and self.y < height;
    }
    pub fn equals(self: @This(), other: Vec2) bool {
        return self.x == other.x and self.y == other.y;
    }
    pub fn add(self: @This(), vec: Vec2) Vec2 {
        return Vec2{ .x = self.x + vec.x, .y = self.y + vec.y };
    }
    pub fn sub(self: @This(), vec: Vec2) Vec2 {
        return Vec2{ .x = self.x - vec.x, .y = self.y - vec.y };
    }
    pub fn multV(self: @This(), vec: Vec2) Vec2 {
        return Vec2{ .x = self.x * vec.x, .y = self.y * vec.y };
    }
    pub fn multS(self: @This(), scalar: i32) Vec2 {
        return Vec2{ .x = self.x * scalar, .y = self.y * scalar };
    }
};

fn calc1(alloc: std.mem.Allocator) !i32 {
    var chars = std.AutoHashMap(i32, std.ArrayList(Vec2)).init(alloc);
    defer chars.deinit();
    defer {
        var values = chars.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
    }

    var x: i32 = 0;
    var y: i32 = 0;
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        for (line) |c| {
            if (c != '.') {
                var list = chars.get(c) orelse try std.ArrayList(Vec2).initCapacity(alloc, 5);
                try list.append(Vec2{ .x = x, .y = y });
                try chars.put(c, list);
            }
            x += 1;
        }
        y += 1;
        x = 0;
    }

    var antinodes = std.AutoHashMap(Vec2, void).init(alloc);
    defer antinodes.deinit();
    var iter = chars.iterator();
    while (iter.next()) |pair| {
        const list = pair.value_ptr.*;
        for (0..list.items.len) |i| {
            for (0..list.items.len) |j| {
                if (i == j) {
                    continue;
                }
                const diff = list.items[j].sub(list.items[i]);
                const antinode = list.items[j].add(diff);
                if (antinode.inBounds(w, h)) {
                    try antinodes.put(antinode, {});
                }
            }
        }
    }

    return @intCast(antinodes.count());
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var chars = std.AutoHashMap(i32, std.ArrayList(Vec2)).init(alloc);
    defer chars.deinit();
    defer {
        var values = chars.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
    }

    var x: i32 = 0;
    var y: i32 = 0;
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        for (line) |c| {
            if (c != '.') {
                var list = chars.get(c) orelse try std.ArrayList(Vec2).initCapacity(alloc, 5);
                try list.append(Vec2{ .x = x, .y = y });
                try chars.put(c, list);
            }
            x += 1;
        }
        y += 1;
        x = 0;
    }

    var antinodes = std.AutoHashMap(Vec2, void).init(alloc);
    defer antinodes.deinit();
    var iter = chars.iterator();
    while (iter.next()) |pair| {
        const list = pair.value_ptr.*;
        for (0..list.items.len) |i| {
            for (0..list.items.len) |j| {
                if (i == j) {
                    continue;
                }
                const diff = list.items[j].sub(list.items[i]);
                var step: i32 = 0;
                while (true) {
                    step += 1;
                    const antinode = list.items[i].add(diff.multS(step));
                    if (antinode.inBounds(w, h)) {
                        try antinodes.put(antinode, {});
                    } else {
                        break;
                    }
                }
            }
        }
    }

    return @intCast(antinodes.count());
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
