const std = @import("std");

const INPUT = @embedFile("./input.txt");

fn calc1(alloc: std.mem.Allocator) !u64 {
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");

    var registers: [3]u64 = undefined;
    @memset(&registers, 0);
    registers[0] = try std.fmt.parseInt(u64, lines.next().?[12..], 10);
    registers[1] = try std.fmt.parseInt(u64, lines.next().?[12..], 10);
    registers[2] = try std.fmt.parseInt(u64, lines.next().?[12..], 10);

    const getComboVal = struct {
        pub fn do(val: u64, reg: *[3]u64) u64 {
            if (val < 4) {
                return val;
            } else {
                return reg[@intCast(val - 4)];
            }
        }
    }.do;

    var program = std.ArrayList(u64).init(alloc);
    defer program.deinit();
    var nums = std.mem.tokenizeAny(u8, lines.next().?[9..], ",");
    while (nums.next()) |num| {
        try program.append(try std.fmt.parseInt(u64, num, 10));
    }

    var output = std.ArrayList(u64).init(alloc);
    defer output.deinit();

    var i: usize = 0;
    while (i < program.items.len) {
        const op = program.items[i];
        const val = program.items[i + 1];
        var jumped = false;

        if (op == 0) {
            registers[0] = registers[0] >> @intCast(getComboVal(val, &registers));
        } else if (op == 1) {
            registers[1] = registers[1] ^ val;
        } else if (op == 2) {
            registers[1] = @rem(getComboVal(val, &registers), 8);
        } else if (op == 3) {
            if (registers[0] != 0) {
                i = @intCast(val);
                jumped = true;
            }
        } else if (op == 4) {
            registers[1] = registers[1] ^ registers[2];
        } else if (op == 5) {
            try output.append(@rem(getComboVal(val, &registers), 8));
        } else if (op == 6) {
            registers[1] = registers[0] >> @intCast(getComboVal(val, &registers));
        } else if (op == 7) {
            registers[2] = registers[0] >> @intCast(getComboVal(val, &registers));
        }

        if (!jumped) {
            i += 2;
        }
    }

    std.debug.print("Regs:\n", .{});
    for (registers) |r| {
        std.debug.print("{d}\n", .{r});
    }

    std.debug.print("Output:\n", .{});
    for (0..output.items.len) |n| {
        if (n == output.items.len - 1) {
            std.debug.print("{d}\n", .{output.items[n]});
        } else {
            std.debug.print("{d},", .{output.items[n]});
        }
    }

    return 99999;
}

fn calc2(alloc: std.mem.Allocator) !u64 {
    var lines = std.mem.tokenizeAny(u8, INPUT, "\r\n");

    var registers: [3]u64 = undefined;
    @memset(&registers, 0);
    registers[0] = try std.fmt.parseInt(u64, lines.next().?[12..], 10);
    registers[1] = try std.fmt.parseInt(u64, lines.next().?[12..], 10);
    registers[2] = try std.fmt.parseInt(u64, lines.next().?[12..], 10);

    const getComboVal = struct {
        pub fn do(val: u64, reg: *[3]u64) u64 {
            if (val < 4) {
                return val;
            } else {
                return reg[@intCast(val - 4)];
            }
        }
    }.do;

    var program = std.ArrayList(u64).init(alloc);
    defer program.deinit();
    var nums = std.mem.tokenizeAny(u8, lines.next().?[9..], ",");
    while (nums.next()) |num| {
        try program.append(try std.fmt.parseInt(u64, num, 10));
    }

    var base: u64 = 0b101001011110111110100;
    var baseDigits: u6 = 21;
    var bestLength: usize = 0;
    var _a: u64 = 0;
    loop: while (true) {
        const a: u64 = (_a << baseDigits) | base;
        // std.debug.print("a: {d} | b: {b}\n", .{ a, a });
        registers[0] = a;
        registers[1] = 0;
        registers[2] = 0;

        _a += 1;

        var output = std.ArrayList(u64).init(alloc);
        defer output.deinit();

        var i: usize = 0;
        while (i < program.items.len) {
            const op = program.items[i];
            const val = program.items[i + 1];
            var jumped = false;

            if (op == 0) {
                registers[0] = registers[0] >> @intCast(getComboVal(val, &registers));
            } else if (op == 1) {
                registers[1] = registers[1] ^ val;
            } else if (op == 2) {
                registers[1] = @rem(getComboVal(val, &registers), 8);
            } else if (op == 3) {
                if (registers[0] != 0) {
                    i = @intCast(val);
                    jumped = true;
                }
            } else if (op == 4) {
                registers[1] = registers[1] ^ registers[2];
            } else if (op == 5) {
                const v = @rem(getComboVal(val, &registers), 8);
                if (v != program.items[output.items.len]) {
                    if (output.items.len > bestLength) {
                        bestLength = output.items.len;
                        base = a;
                        baseDigits = std.math.log2_int(u64, a) + 1;
                        std.debug.print("a: {d} | b: {b} | out: {any}\n", .{ a, a, output.items });
                        _a = 1;
                    }
                    continue :loop;
                }
                try output.append(v);
            } else if (op == 6) {
                registers[1] = registers[0] >> @intCast(getComboVal(val, &registers));
            } else if (op == 7) {
                registers[2] = registers[0] >> @intCast(getComboVal(val, &registers));
            }

            if (!jumped) {
                i += 2;
            }
        }

        if (std.mem.eql(u64, output.items, program.items)) {
            return a;
        }
    }

    return 888888;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
