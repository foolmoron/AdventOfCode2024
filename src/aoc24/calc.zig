const std = @import("std");

const INPUT = @embedFile("./input.txt");

const Node1Type = enum {
    Literal,
    And,
    Xor,
    Or,
};

const Node1 = struct {
    t: Node1Type,
    arg1: [3]u8 = undefined,
    arg2: [3]u8 = undefined,
    val: ?u1 = null,
};

fn evalAndCache(n: *Node1, map: *std.AutoHashMap([3]u8, Node1)) u1 {
    if (n.val == null) {
        const val = switch (n.t) {
            Node1Type.Literal => n.val.?,
            Node1Type.And => evalAndCache(map.getPtr(n.arg1).?, map) & evalAndCache(map.getPtr(n.arg2).?, map),
            Node1Type.Xor => evalAndCache(map.getPtr(n.arg1).?, map) ^ evalAndCache(map.getPtr(n.arg2).?, map),
            Node1Type.Or => evalAndCache(map.getPtr(n.arg1).?, map) | evalAndCache(map.getPtr(n.arg2).?, map),
        };
        n.val = val;
    }
    return n.val.?;
}

fn calc1(alloc: std.mem.Allocator) !i64 {
    var chunks = std.mem.tokenizeSequence(u8, INPUT, "\n\n");
    const chunk1 = chunks.next().?;
    const chunk2 = chunks.next().?;

    var map = std.AutoHashMap([3]u8, Node1).init(alloc);
    defer map.deinit();

    var split1 = std.mem.tokenizeAny(u8, chunk1, "\r\n");
    while (split1.next()) |line| {
        try map.put(line[0..3].*, Node1{
            .t = Node1Type.Literal,
            .val = try std.fmt.parseInt(u1, line[5..6], 2),
        });
    }

    var split2 = std.mem.tokenizeAny(u8, chunk2, "\r\n");
    while (split2.next()) |line| {
        if (std.mem.indexOf(u8, line, "AND") != null) {
            try map.put(line[15..18].*, Node1{
                .t = Node1Type.And,
                .arg1 = line[0..3].*,
                .arg2 = line[8..11].*,
            });
        } else if (std.mem.indexOf(u8, line, "XOR") != null) {
            try map.put(line[15..18].*, Node1{
                .t = Node1Type.Xor,
                .arg1 = line[0..3].*,
                .arg2 = line[8..11].*,
            });
        } else if (std.mem.indexOf(u8, line, "OR") != null) {
            try map.put(line[14..17].*, Node1{
                .t = Node1Type.Or,
                .arg1 = line[0..3].*,
                .arg2 = line[7..10].*,
            });
        }
    }

    var iter1 = map.iterator();
    var bits: usize = 0;
    while (iter1.next()) |pair| {
        const key = pair.key_ptr.*;
        if (key[0] != 'z') {
            continue;
        }
        bits = @max(bits, try std.fmt.parseInt(usize, key[1..3], 10));
        _ = evalAndCache(pair.value_ptr, &map);
    }

    var sum: i64 = 0;
    for (0..bits + 1) |b| {
        var key: [3]u8 = undefined;
        key[0] = 'z';
        _ = std.fmt.bufPrintIntToSlice(key[1..3], b, 10, .lower, .{ .width = 2, .fill = '0' });
        const val: i64 = @intCast(map.get(key).?.val.?);
        // std.debug.print("{s}: {any}\n", .{ key, val });
        sum |= val << @intCast(b);
    }

    return sum;
}

fn testPairs(a1: [3]u8, a2: [3]u8, b1: [3]u8, b2: [3]u8, c1: [3]u8, c2: [3]u8, d1: [3]u8, d2: [3]u8, map: *std.AutoHashMap([3]u8, Node1)) i64 {
    _ = a1; // autofix
    _ = a2; // autofix
    _ = b1; // autofix
    _ = b2; // autofix
    _ = c1; // autofix
    _ = c2; // autofix
    _ = d1; // autofix
    _ = d2; // autofix
    _ = map; // autofix
    return 0;
}

fn calc2(alloc: std.mem.Allocator) !i64 {
    var chunks = std.mem.tokenizeSequence(u8, INPUT, "\n\n");
    const chunk1 = chunks.next().?;
    const chunk2 = chunks.next().?;

    var map = std.AutoHashMap([3]u8, Node1).init(alloc);
    defer map.deinit();

    var split1 = std.mem.tokenizeAny(u8, chunk1, "\r\n");
    while (split1.next()) |line| {
        try map.put(line[0..3].*, Node1{
            .t = Node1Type.Literal,
            .val = try std.fmt.parseInt(u1, line[5..6], 2),
        });
    }

    var split2 = std.mem.tokenizeAny(u8, chunk2, "\r\n");
    while (split2.next()) |line| {
        if (std.mem.indexOf(u8, line, "AND") != null) {
            try map.put(line[15..18].*, Node1{
                .t = Node1Type.And,
                .arg1 = line[0..3].*,
                .arg2 = line[8..11].*,
            });
        } else if (std.mem.indexOf(u8, line, "XOR") != null) {
            try map.put(line[15..18].*, Node1{
                .t = Node1Type.Xor,
                .arg1 = line[0..3].*,
                .arg2 = line[8..11].*,
            });
        } else if (std.mem.indexOf(u8, line, "OR") != null) {
            try map.put(line[14..17].*, Node1{
                .t = Node1Type.Or,
                .arg1 = line[0..3].*,
                .arg2 = line[7..10].*,
            });
        }
    }

    var keys = std.ArrayList([3]u8).init(alloc);
    defer keys.deinit();
    var iter = map.keyIterator();
    while (iter.next()) |key| {
        try keys.append(key.*);
    }

    const n = keys.items.len;
    const target: u64 = 999;
    for (0..n) |a1| {
        for (0..n) |a2| {
            for (0..n) |b1| {
                for (0..n) |b2| {
                    for (0..n) |c1| {
                        for (0..n) |c2| {
                            for (0..n) |d1| {
                                for (0..n) |d2| {
                                    const val = testPairs(keys.items[a1], keys.items[a2], keys.items[b1], keys.items[b2], keys.items[c1], keys.items[c2], keys.items[d1], keys.items[d2], &map);
                                    if (val != target) {
                                        continue;
                                    }
                                    var set = std.AutoHashMap(usize, void).init(alloc);
                                    defer set.deinit();
                                    try set.put(a1, {});
                                    try set.put(a2, {});
                                    try set.put(b1, {});
                                    try set.put(b2, {});
                                    try set.put(c1, {});
                                    try set.put(c2, {});
                                    try set.put(d1, {});
                                    try set.put(d2, {});
                                    if (set.count() != 8) {
                                        continue;
                                    }
                                    var list = std.ArrayList([3]u8).init(alloc);
                                    defer list.deinit();
                                    try list.append(keys.items[a1]);
                                    try list.append(keys.items[a2]);
                                    try list.append(keys.items[b1]);
                                    try list.append(keys.items[b2]);
                                    try list.append(keys.items[c1]);
                                    try list.append(keys.items[c2]);
                                    try list.append(keys.items[d1]);
                                    try list.append(keys.items[d2]);
                                    std.mem.sort([3]u8, list.items, {}, struct {
                                        pub fn do(_: void, a: [3]u8, b: [3]u8) bool {
                                            return std.ascii.lessThanIgnoreCase(&a, &b);
                                        }
                                    }.do);
                                    std.debug.print("{s}\n", .{list.items});
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return 0;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
