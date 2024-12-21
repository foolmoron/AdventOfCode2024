const std = @import("std");
const aoc1 = @import("aoc1/calc.zig");
const aoc2 = @import("aoc2/calc.zig");
const aoc3 = @import("aoc3/calc.zig");
const aoc4 = @import("aoc4/calc.zig");
const aoc5 = @import("aoc5/calc.zig");
const aoc6 = @import("aoc6/calc.zig");
const aoc7 = @import("aoc7/calc.zig");
const aoc8 = @import("aoc8/calc.zig");
const aoc9 = @import("aoc9/calc.zig");
const aoc10 = @import("aoc10/calc.zig");
const aoc11 = @import("aoc11/calc.zig");
const aoc12 = @import("aoc12/calc.zig");
const aoc13 = @import("aoc13/calc.zig");
const aoc14 = @import("aoc14/calc.zig");
// const aoc15 = @import("aoc15/calc.zig");
const aoc16 = @import("aoc16/calc.zig");
const aoc17 = @import("aoc17/calc.zig");
const aoc18 = @import("aoc18/calc.zig");
const aoc19 = @import("aoc19/calc.zig");
const aoc20 = @import("aoc20/calc.zig");
// const aoc21 = @import("aoc21/calc.zig");
// const aoc22 = @import("aoc22/calc.zig");
// const aoc23 = @import("aoc23/calc.zig");
// const aoc24 = @import("aoc24/calc.zig");
// const aoc25 = @import("aoc25/calc.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    const n = if (args.len > 1) std.fmt.parseInt(i32, args[1], 10) catch 1 else 17;
    switch (n) {
        1 => try aoc1.calc(alloc),
        2 => try aoc2.calc(alloc),
        3 => try aoc3.calc(alloc),
        4 => try aoc4.calc(alloc),
        5 => try aoc5.calc(alloc),
        6 => try aoc6.calc(alloc),
        7 => try aoc7.calc(alloc),
        8 => try aoc8.calc(alloc),
        9 => try aoc9.calc(alloc),
        10 => try aoc10.calc(alloc),
        11 => try aoc11.calc(alloc),
        12 => try aoc12.calc(alloc),
        13 => try aoc13.calc(alloc),
        14 => try aoc14.calc(alloc),
        // 15 => try aoc15.calc(alloc),
        16 => try aoc16.calc(alloc),
        17 => try aoc17.calc(alloc),
        18 => try aoc18.calc(alloc),
        19 => try aoc19.calc(alloc),
        20 => try aoc20.calc(alloc),
        // 21 => try aoc21.calc(alloc),
        // 22 => try aoc22.calc(alloc),
        // 23 => try aoc23.calc(alloc),
        // 24 => try aoc24.calc(alloc),
        // 25 => try aoc25.calc(alloc),
        else => return error.Unreachable,
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
