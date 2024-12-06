const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn calc1(alloc: std.mem.Allocator) !i32 {
    var deps = std.AutoHashMap(i32, std.ArrayList(i32)).init(alloc);
    defer deps.deinit();
    defer {
        var values = deps.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
    }

    var chunks = std.mem.tokenizeSequence(u8, INPUT, "\r\n\r\n");
    var lines1 = std.mem.tokenizeAny(u8, chunks.next().?, "\r\n");
    while (lines1.next()) |line| {
        const n1 = try std.fmt.parseInt(i32, line[0..2], 10);
        const n2 = try std.fmt.parseInt(i32, line[3..5], 10);
        var list = deps.get(n2) orelse try std.ArrayList(i32).initCapacity(alloc, 10);
        try list.append(n1);
        try deps.put(n2, list);
    }
    var sum: i32 = 0;
    var lines2 = std.mem.tokenizeAny(u8, chunks.next().?, "\r\n");
    while (lines2.next()) |line| {
        var nums_it = std.mem.tokenizeAny(u8, line, ",");
        var nums = try std.ArrayList(i32).initCapacity(alloc, 10);
        defer nums.deinit();
        while (nums_it.next()) |num| {
            try nums.append(try std.fmt.parseInt(i32, num, 10));
        }

        var seen = try std.ArrayList(i32).initCapacity(alloc, 10);
        defer seen.deinit();

        var valid = true;
        for (nums.items) |n| {
            // std.debug.print("-{any}-\n", .{n});
            if (deps.get(n)) |dep| {
                for (dep.items) |d| {
                    var containsNums = false;
                    for (nums.items) |i| {
                        if (i == d) {
                            containsNums = true;
                            break;
                        }
                    }
                    var containsSeen = false;
                    for (seen.items) |i| {
                        if (i == d) {
                            containsSeen = true;
                            break;
                        }
                    }
                    if (containsNums and !containsSeen) {
                        valid = false;
                        break;
                    }
                    // std.debug.print("{any}: {any}/{any}\n", .{ d, containsNums, containsSeen });
                }
                if (!valid) {
                    break;
                }
            }
            // std.debug.print("\n", .{});
            try seen.append(n);
        }
        // std.debug.print("\n---{any}---\n\n", .{valid});
        if (valid) {
            sum += nums.items[nums.items.len / 2];
        }
    }
    return sum;
}

fn depth(map: std.AutoHashMap(i32, std.ArrayList(i32)), nums: std.ArrayList(i32), memo: *std.AutoHashMap(i32, i32), num: i32, d: i32) i32 {
    if (memo.get(num)) |m| {
        return m;
    }
    var m: i32 = -1;
    if (map.get(num)) |deps| {
        var dMax: i32 = -1;
        for (deps.items) |dep| {
            var contains = false;
            for (nums.items) |n| {
                if (n == dep) {
                    contains = true;
                    break;
                }
            }
            if (!contains) {
                continue;
            }
            const d2 = depth(map, nums, memo, dep, d - 1);
            if (d2 > dMax) {
                dMax = d2;
            }
        }
        m = dMax + 1;
    } else {
        m = d;
    }
    memo.put(num, m) catch {};
    return m;
}

fn depthComp(ctx: struct { std.AutoHashMap(i32, std.ArrayList(i32)), std.ArrayList(i32), *std.AutoHashMap(i32, i32) }, a: i32, b: i32) bool {
    return depth(ctx[0], ctx[1], ctx[2], a, 0) < depth(ctx[0], ctx[1], ctx[2], b, 0);
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var deps = std.AutoHashMap(i32, std.ArrayList(i32)).init(alloc);
    defer deps.deinit();
    defer {
        var values = deps.valueIterator();
        while (values.next()) |value| {
            value.deinit();
        }
    }

    var chunks = std.mem.tokenizeSequence(u8, INPUT, "\r\n\r\n");
    const chunk1 = chunks.next().?;
    const chunk2 = chunks.next().?;

    var lines1 = std.mem.tokenizeAny(u8, chunk1, "\r\n");
    while (lines1.next()) |line| {
        const n1 = try std.fmt.parseInt(i32, line[0..2], 10);
        const n2 = try std.fmt.parseInt(i32, line[3..5], 10);
        var list = deps.get(n2) orelse try std.ArrayList(i32).initCapacity(alloc, 10);
        try list.append(n1);
        try deps.put(n2, list);
    }

    var sum: i32 = 0;
    var lines2 = std.mem.tokenizeAny(u8, chunk2, "\r\n");
    while (lines2.next()) |line| {
        var memo = std.AutoHashMap(i32, i32).init(alloc);
        defer memo.deinit();

        var nums_it = std.mem.tokenizeAny(u8, line, ",");
        var nums = try std.ArrayList(i32).initCapacity(alloc, 10);
        defer nums.deinit();
        while (nums_it.next()) |num| {
            try nums.append(try std.fmt.parseInt(i32, num, 10));
        }

        var seen = try std.ArrayList(i32).initCapacity(alloc, 10);
        defer seen.deinit();

        var valid = true;
        for (nums.items) |n| {
            // std.debug.print("-{any}-\n", .{n});
            if (deps.get(n)) |dep| {
                for (dep.items) |d| {
                    var containsNums = false;
                    for (nums.items) |i| {
                        if (i == d) {
                            containsNums = true;
                            break;
                        }
                    }
                    var containsSeen = false;
                    for (seen.items) |i| {
                        if (i == d) {
                            containsSeen = true;
                            break;
                        }
                    }
                    if (containsNums and !containsSeen) {
                        valid = false;
                        break;
                    }
                    // std.debug.print("{any}: {any}/{any}\n", .{ d, containsNums, containsSeen });
                }
                if (!valid) {
                    break;
                }
            }
            // std.debug.print("\n", .{});
            try seen.append(n);
        }
        // std.debug.print("\n---{any}---\n\n", .{valid});
        if (valid) {
            continue;
        } else {
            std.mem.sort(i32, nums.items, .{ deps, nums, &memo }, depthComp);
            sum += nums.items[nums.items.len / 2];
            // std.debug.print("---{any}---\n", .{nums.items});
        }
    }
    return sum;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
