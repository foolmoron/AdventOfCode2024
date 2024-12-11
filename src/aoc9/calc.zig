const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn calc1(alloc: std.mem.Allocator) !u64 {
    var len: u64 = 0;
    for (INPUT) |c| {
        const n: usize = c - '0';
        len += n;
    }

    const arr = try alloc.alloc(u16, len);
    defer alloc.free(arr);
    @memset(arr, std.math.maxInt(u16));

    var i: u64 = 0;
    var id: u16 = 0;
    var isEmpty = false;
    for (INPUT) |c| {
        const n: usize = c - '0';
        // std.debug.print("{any} {any} {any}\n", .{ c, n, isEmpty });
        if (isEmpty) {
            i += n;
        } else {
            for (0..n) |_| {
                arr[i] = id;
                i += 1;
            }
            id += 1;
        }
        isEmpty = !isEmpty;
    }
    // std.debug.print("{any}\n", .{arr});

    var end = arr.len - 1;
    for (0..arr.len) |a| {
        if (arr[a] != std.math.maxInt(u16)) {
            continue;
        }
        while (end >= 0 and arr[end] == std.math.maxInt(u16)) {
            end -= 1;
        }
        if (a >= end) {
            break;
        }
        // std.debug.print("swap {any}({any}) => {any}({any})\n", .{ a, arr[a], end, arr[end] });
        arr[a] = arr[end];
        arr[end] = std.math.maxInt(u16);
    }
    // std.debug.print("{any}\n{any}\n", .{ end, arr });

    var sum: u64 = 0;
    for (0..arr.len) |a| {
        if (arr[a] == std.math.maxInt(u16)) {
            continue;
        }
        sum += a * arr[a];
    }

    return sum;
}

fn calc2(alloc: std.mem.Allocator) !u64 {
    var len: u64 = 0;
    for (INPUT) |c| {
        const n: usize = c - '0';
        len += n;
    }

    const arr = try alloc.alloc(u16, len);
    defer alloc.free(arr);
    @memset(arr, std.math.maxInt(u16));

    var i: u64 = 0;
    var id: u16 = 0;
    var isEmpty = false;
    for (INPUT) |c| {
        const n: usize = c - '0';
        // std.debug.print("{any} {any} {any}\n", .{ c, n, isEmpty });
        if (isEmpty) {
            i += n;
        } else {
            for (0..n) |_| {
                arr[i] = id;
                i += 1;
            }
            id += 1;
        }
        isEmpty = !isEmpty;
    }
    // std.debug.print("{any}\n", .{arr});

    var currBlockStart: usize = arr.len - 1;
    var currBlockNum: u16 = arr[arr.len - 1];
    var minBlockNum: u16 = currBlockNum;
    var currBlockLen: usize = 1;
    while (true) {
        while (currBlockStart > 0 and arr[currBlockStart] == std.math.maxInt(u16)) {
            currBlockStart -= 1;
            currBlockLen = 1;
            currBlockNum = arr[currBlockStart];
            minBlockNum = @min(minBlockNum, currBlockNum);
            // std.debug.print("moving1 to {any} #{any} - {any}/{any}\n", .{ currBlockStart, arr[currBlockStart], minBlockNum, currBlockNum });
        }
        while (currBlockStart > 0 and arr[currBlockStart - 1] == currBlockNum) {
            currBlockStart -= 1;
            currBlockLen += 1;
            // std.debug.print("block of {} = [{any}, {any}] => {any}\n", .{ currBlockNum, currBlockStart, currBlockLen, arr[currBlockStart] });
        }
        // std.debug.print("mincurr1 {any}/{any} l{any}\n", .{ minBlockNum, currBlockNum, currBlockLen });

        var currSpaceStart: usize = 0;
        var currSpaceLen: usize = 1;
        while (currSpaceStart < currBlockStart and currSpaceLen <= currBlockLen) {
            while (currSpaceStart < arr.len - 1 and arr[currSpaceStart] != std.math.maxInt(u16)) {
                currSpaceStart += 1;
                currSpaceLen = 1;
            }
            while (currSpaceStart + currSpaceLen < arr.len - 1 and arr[currSpaceStart + currSpaceLen] == std.math.maxInt(u16)) {
                currSpaceLen += 1;
            }
            // std.debug.print("checking [{any}, {any}] vs [{any}, {any}]\n", .{ currSpaceStart, currSpaceLen, currBlockStart, currBlockLen });
            if (currSpaceStart + currSpaceLen >= currBlockStart or currSpaceLen >= currBlockLen) {
                break;
            } else if (currSpaceLen < currBlockLen) {
                currSpaceStart += 1;
                currSpaceLen = 1;
            }
        }
        // std.debug.print("check done [{any}, {any}] vs [{any}, {any}]\n", .{ currSpaceStart, currSpaceLen, currBlockStart, currBlockLen });
        if (currBlockNum == minBlockNum and currSpaceLen >= currBlockLen and arr[currSpaceStart] == std.math.maxInt(u16)) {
            // move
            for (0..currBlockLen) |c| {
                arr[currSpaceStart + c] = arr[currBlockStart + c];
                arr[currBlockStart + c] = std.math.maxInt(u16);
            }
            // std.debug.print("move2 {any} to {any} - {any}/{any}\n", .{ currBlockStart, currSpaceStart, currBlockNum, minBlockNum });
            // std.debug.print("{any}\n", .{arr});
        }

        if (currBlockStart <= 0) {
            break;
        }

        currBlockStart -= 1;
        currBlockLen = 1;
        currBlockNum = arr[currBlockStart];
        minBlockNum = @min(minBlockNum, currBlockNum);
    }
    // std.debug.print("{any}\n", .{arr});

    var sum: u64 = 0;
    for (0..arr.len) |a| {
        if (arr[a] == std.math.maxInt(u16)) {
            continue;
        }
        sum += a * arr[a];
    }

    return sum;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
