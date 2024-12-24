const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn calc1(alloc: std.mem.Allocator) !i32 {
    var map = std.AutoHashMap([2]u8, std.ArrayList([2]u8)).init(alloc);
    defer map.deinit();
    defer {
        var values = map.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
    }

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        const s1: [2]u8 = line[0..2].*;
        const s2: [2]u8 = line[3..5].*;
        var l1 = map.get(s1) orelse try std.ArrayList([2]u8).initCapacity(alloc, 4);
        try l1.append(s2);
        try map.put(s1, l1);
        var l2 = map.get(s2) orelse try std.ArrayList([2]u8).initCapacity(alloc, 4);
        try l2.append(s1);
        try map.put(s2, l2);
    }

    var valids = std.AutoHashMap([3][2]u8, void).init(alloc);
    defer valids.deinit();

    var pairs = map.iterator();
    while (pairs.next()) |pair| {
        const first: [2]u8 = pair.key_ptr.*[0..2].*;
        const l1 = pair.value_ptr.*;
        for (l1.items) |second| {
            const l2 = map.get(second) orelse return error.Unreachable;
            for (l2.items) |third| {
                var contains = false;
                for (l1.items) |first2| {
                    if (!std.mem.eql(u8, &first, &first2) and std.mem.eql(u8, &first2, &third)) {
                        contains = true;
                        break;
                    }
                }
                if (contains) {
                    var set: [3][2]u8 = undefined;
                    set[0] = first;
                    set[1] = second;
                    set[2] = third;
                    std.mem.sort([2]u8, &set, {}, struct {
                        pub fn do(_: void, a: [2]u8, b: [2]u8) bool {
                            return std.ascii.lessThanIgnoreCase(&a, &b);
                        }
                    }.do);
                    try valids.put(set, {});
                }
            }
        }
    }

    var count: i32 = 0;
    var iter = valids.keyIterator();
    while (iter.next()) |key| {
        const set = key.*;
        if (set[0][0] == 't' or set[1][0] == 't' or set[2][0] == 't') {
            count += 1;
            // std.debug.print("{s},{s},{s}\n", .{ set[0], set[1], set[2] });
        }
    }

    return count;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var map = std.AutoHashMap([2]u8, std.ArrayList([2]u8)).init(alloc);
    defer map.deinit();
    defer {
        var values = map.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
    }

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        const s1: [2]u8 = line[0..2].*;
        const s2: [2]u8 = line[3..5].*;
        var l1 = map.get(s1) orelse try std.ArrayList([2]u8).initCapacity(alloc, 4);
        try l1.append(s2);
        try map.put(s1, l1);
        var l2 = map.get(s2) orelse try std.ArrayList([2]u8).initCapacity(alloc, 4);
        try l2.append(s1);
        try map.put(s2, l2);
    }

    var biggest: usize = 0;
    var pairs = map.iterator();
    while (pairs.next()) |pair| {
        const key = pair.key_ptr.*[0..2].*;
        var clique = std.AutoHashMap([2]u8, void).init(alloc);
        defer clique.deinit();

        var remainder = std.ArrayList([2]u8).init(alloc);
        defer remainder.deinit();
        var iter = map.keyIterator();
        while (iter.next()) |item| {
            try remainder.append(item.*);
        }

        var q = std.ArrayList([2]u8).init(alloc);
        defer q.deinit();
        try q.append(key);

        while (q.items.len > 0 and remainder.items.len > 0) {
            const node = q.orderedRemove(0);

            var valid = false;
            for (remainder.items) |item| {
                if (std.mem.eql(u8, &node, &item)) {
                    valid = true;
                    break;
                }
            }

            if (valid) {
                try clique.put(node, {});
                const connected = map.get(node) orelse return error.Unreachable;
                for (connected.items) |item| {
                    if (!clique.contains(item)) {
                        try q.append(item);
                    }
                }
                var i: usize = remainder.items.len;
                while (i > 0) {
                    var contains = false;
                    for (connected.items) |c| {
                        if (std.mem.eql(u8, &c, &remainder.items[i - 1])) {
                            contains = true;
                            break;
                        }
                    }
                    if (!contains) {
                        _ = remainder.swapRemove(i - 1);
                    }
                    i -= 1;
                }
            }
        }

        if (clique.count() > biggest) {
            biggest = clique.count();

            var set = std.ArrayList([]const u8).init(alloc);
            defer set.deinit();

            var keys = clique.keyIterator();
            while (keys.next()) |item| {
                try set.append(item);
            }
            std.mem.sort([]const u8, set.items, {}, struct {
                pub fn do(_: void, a: []const u8, b: []const u8) bool {
                    return std.ascii.lessThanIgnoreCase(a, b);
                }
            }.do);

            const str = try std.mem.join(alloc, ",", set.items);
            defer alloc.free(str);

            std.debug.print("{s} [{any}]\n{s}\n", .{ key, biggest, str });
        }
    }

    return @intCast(biggest);
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
