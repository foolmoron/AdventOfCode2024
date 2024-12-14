const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn run1(nums: *std.ArrayList(u64)) !void {
    var i: usize = 0;
    while (i < nums.items.len) {
        const num = nums.items[i];
        if (num == 0) {
            nums.items[i] = 1;
        } else {
            const digits: u64 = std.math.log10(num) + 1;
            if (digits % 2 == 0) {
                const divisor = try std.math.powi(u64, 10, digits / 2);
                const first = num / divisor;
                const second = num % divisor;
                try nums.insert(i, first);
                nums.items[i + 1] = second;
                i += 1;
            } else {
                nums.items[i] = num * 2024;
            }
        }
        i += 1;
    }
}

fn calc1(alloc: std.mem.Allocator) !u64 {
    var nums = std.ArrayList(u64).init(alloc);
    defer nums.deinit();
    var iter = std.mem.tokenizeAny(u8, INPUT, " ");
    while (iter.next()) |str| {
        const n = try std.fmt.parseInt(u64, str, 10);
        try nums.append(n);
    }

    for (0..25) |i| {
        _ = i; // autofix
        try run1(&nums);
        // std.debug.print("{any} => {any}\n", .{ i, nums.items });
    }

    return @intCast(nums.items.len);
}

const NumTimes = struct {
    num: u64 = 0,
    times: u64 = 0,
};

fn runNumNTimes(numTimes: NumTimes, memo: *std.AutoHashMap(NumTimes, u64)) !u64 {
    const num = numTimes.num;
    const times = numTimes.times;
    if (times == 0) {
        return 1;
    }
    if (memo.get(numTimes)) |count| {
        return count;
    }
    var count: u64 = 0;
    if (num == 0) {
        count = try runNumNTimes(NumTimes{ .num = 1, .times = times - 1 }, memo);
    } else {
        const digits: u64 = std.math.log10(num) + 1;
        if (digits % 2 == 0) {
            const divisor = try std.math.powi(u64, 10, digits / 2);
            const first = num / divisor;
            const second = num % divisor;
            const firstCount = try runNumNTimes(NumTimes{ .num = first, .times = times - 1 }, memo);
            const secondCount = try runNumNTimes(NumTimes{ .num = second, .times = times - 1 }, memo);
            count = firstCount + secondCount;
        } else {
            count = try runNumNTimes(NumTimes{ .num = num * 2024, .times = times - 1 }, memo);
        }
    }
    try memo.put(numTimes, count);
    return count;
}

fn calc2(alloc: std.mem.Allocator) !u64 {
    var nums = std.ArrayList(u64).init(alloc);
    defer nums.deinit();
    var iter = std.mem.tokenizeAny(u8, INPUT, " ");
    while (iter.next()) |str| {
        const n = try std.fmt.parseInt(u64, str, 10);
        try nums.append(n);
    }

    var memo = std.AutoHashMap(NumTimes, u64).init(alloc);
    defer memo.deinit();

    var sum: u64 = 0;
    for (nums.items) |num| {
        // std.debug.print("n {any}\n", .{num});
        const count = try runNumNTimes(NumTimes{ .num = num, .times = 75 }, &memo);
        sum += @intCast(count);
    }

    return sum;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    // std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
