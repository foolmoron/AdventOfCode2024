const std = @import("std");
const Regex = @import("regex").Regex;
const Captures = @import("regex").Captures;

const INPUT = @embedFile("./input.txt");

fn calc1(alloc: std.mem.Allocator) !i32 {
    var re = try Regex.compile(alloc, "mul\\((\\d+),(\\d+)\\)");
    defer re.deinit();

    var sum: i32 = 0;
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        var start: usize = 0;
        while (try re.captures(line[start..])) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            if (captures.boundsAt(0)) |bounds| {
                const mul = line[start + bounds.lower .. start + bounds.upper];
                _ = mul; // autofix
                const n1 = try std.fmt.parseInt(i32, captures.sliceAt(1).?, 10);
                const n2 = try std.fmt.parseInt(i32, captures.sliceAt(2).?, 10);
                sum += n1 * n2;
                start = start + bounds.upper;
                // std.debug.print("{s} = {d} >> {d}\n", .{ mul, n1 * n2, start });
            } else {
                break;
            }
        }
    }
    return sum;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var re = try Regex.compile(alloc, "(mul\\((\\d+),(\\d+)\\)|don't\\(\\)|do\\(\\))");
    defer re.deinit();

    var sum: i32 = 0;
    var enabled = true;
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");
    while (lines.next()) |line| {
        var start: usize = 0;
        while (try re.captures(line[start..])) |*captures| {
            var _captures = captures.*;
            defer _captures.deinit();
            if (captures.sliceAt(0)) |slice| {
                const bounds = captures.boundsAt(0).?;
                if (std.mem.eql(u8, slice, "don't()")) {
                    enabled = false;
                } else if (std.mem.eql(u8, slice, "do()")) {
                    enabled = true;
                } else if (enabled) {
                    const n1 = try std.fmt.parseInt(i32, captures.sliceAt(2).?, 10);
                    const n2 = try std.fmt.parseInt(i32, captures.sliceAt(3).?, 10);
                    sum += n1 * n2;
                }
                start = start + bounds.upper;
            } else {
                break;
            }
        }
    }
    return sum;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
