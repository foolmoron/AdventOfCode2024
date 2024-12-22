const std = @import("std");

const INPUT = @embedFile("./input.txt");
const ITERS = 2000;
const NUMS = blk: {
    @setEvalBranchQuota(100000);
    var count: usize = 0;
    var iter = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (iter.next()) |_| {
        count += 1;
    }
    break :blk count;
};

fn run(num: u24) u24 {
    var new = num;
    // std.debug.print("  num: {d}\n", .{new});
    const shl = @shlWithOverflow(new, 6)[0];
    // std.debug.print("  mul64: {d}\n", .{shl});
    new = new ^ shl;
    // std.debug.print("  mix64: {d}\n", .{new});
    const shr = new >> 5;
    // std.debug.print("  div5: {d}\n", .{shr});
    new = new ^ shr;
    // std.debug.print("  mix5: {d}\n", .{new});
    const shl2 = @shlWithOverflow(new, 11)[0];
    // std.debug.print("  mul11: {d}\n", .{shl2});
    new = new ^ shl2;
    // std.debug.print("  mix11: {d}\n", .{new});
    return new;
}

fn calc1(alloc: std.mem.Allocator) !i64 {
    _ = alloc; // autofix

    var sum: i64 = 0;

    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        var num = try std.fmt.parseInt(u24, line, 10);
        // std.debug.print("{any}: ", .{num});
        for (0..ITERS) |i| {
            _ = i; // autofix
            num = run(num);
            // std.debug.print("{any}: {d}\n", .{ i, num });
        }
        sum += num;
        // std.debug.print("{d}\n", .{num});
    }

    return sum;
}

fn calc2(alloc: std.mem.Allocator) !i64 {
    _ = alloc; // autofix

    // calc u4[ITERS] arr for each num
    var prices: [NUMS * ITERS]u4 = undefined;
    var seqs: [NUMS * ITERS]i8 = undefined;
    {
        var n: usize = 0;
        var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
        while (lines.next()) |line| {
            var num = try std.fmt.parseInt(u24, line, 10);
            prices[n * ITERS] = @intCast(num % 10);
            seqs[n * ITERS] = -127;
            // std.debug.print("{any}: ", .{num});
            for (1..ITERS) |i| {
                const new = run(num);
                prices[n * ITERS + i] = @intCast(new % 10);

                const diff: i8 = if (i == 0) 0 else @intCast(@as(i8, prices[n * ITERS + i]) - @as(i8, prices[n * ITERS + i - 1]));
                seqs[n * ITERS + i] = diff;

                num = new;
                // std.debug.print("{any}: {d} ({d})\n", .{ i, prices[n * ITERS + i], seqs[n * ITERS + i] });
            }
            n += 1;
            // std.debug.print("{d}\n", .{num});
        }
    }

    // for each seq of 4, calc the sum by looking through each arr and adding the num
    var sumBest: i32 = 0;
    for (4..ITERS) |iter| {
        if (iter % 10 == 0) {
            std.debug.print("iter {any}\n", .{iter});
        }
        const seq = seqs[iter - 4 .. iter];
        var sum: i32 = 0;
        for (0..NUMS) |n| {
            for (0..ITERS - 4) |i| {
                if (std.mem.eql(i8, seqs[n * ITERS + i .. n * ITERS + i + 4], seq)) {
                    sum += prices[n * ITERS + i + 3];
                    break;
                }
            }
        }
        if (sum > sumBest) {
            // std.debug.print("new best seq={any} at s{any} sum {d}\n", .{ seq, iter, sum });
            sumBest = sum;
        }
        // std.debug.print("sum {any} of {any} = {d}\n", .{ iter, seq, sum });
    }

    return sumBest;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
