const std = @import("std");

const INPUT = @embedFile("./input.txt");

const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn toIndex(self: @This(), height: usize) usize {
        return @intCast(@as(i32, @intCast(height)) * self.y + self.x);
    }
};

fn calc1(alloc: std.mem.Allocator) !i32 {
    var width: usize = 1;
    var height: usize = 1;
    for (INPUT) |c| {
        if (c == '\n') {
            height += 1;
            width = 0;
        } else {
            width += 1;
        }
    }

    const grid = try alloc.alloc(u8, width * height);
    defer alloc.free(grid);
    var i: usize = 0;
    var pos: usize = 0;
    for (INPUT) |c| {
        if (c == '^') {
            pos = i;
        }
        if (c != '\n' and c != '\r') {
            grid[i] = c;
            i += 1;
        }
    }

    var dir = Vec2{ .x = 0, .y = -1 };
    const addDirToPos = struct {
        fn do(_pos: usize, _dir: Vec2, _w: usize, _h: usize) error{OutOfRange}!usize {
            const next = @as(i32, @intCast(_pos)) + _dir.y * @as(i32, @intCast(_w)) + _dir.x;
            if (next < 0 or @rem(next, @as(i32, @intCast(_h))) >= _w or @divFloor(next, @as(i32, @intCast(_w))) >= _h) {
                return error.OutOfRange;
            }
            return @intCast(next);
        }
    }.do;

    var count: i32 = 0;
    loop: while (true) {
        if (grid[pos] != 'X') {
            grid[pos] = 'X';
            count += 1;
        }
        var next = addDirToPos(pos, dir, width, height) catch break :loop;
        // std.debug.print("{any} {c} > {any}\n", .{ pos, grid[next], dir });
        while (grid[next] == '#') {
            const dir2 = .{ .x = -dir.y, .y = dir.x };
            dir = dir2;
            next = try addDirToPos(pos, dir, width, height);
        }
        pos = next;
    }

    // for (0..height) |y| {
    //     std.debug.print("{s}\n", .{grid[y * height .. y * height + width]});
    // }

    return count;
}

fn calc2(alloc: std.mem.Allocator) !i32 {
    var width: usize = 1;
    var height: usize = 1;
    for (INPUT) |c| {
        if (c == '\n') {
            height += 1;
            width = 0;
        } else {
            width += 1;
        }
    }

    var locations: i32 = 0;
    for (0..width * height) |obj| {
        const grid = try alloc.alloc(u8, width * height);
        defer alloc.free(grid);
        var i: usize = 0;
        var pos = Vec2{};
        for (INPUT) |c| {
            if (c == '^') {
                pos.x = @rem(@as(i32, @intCast(i)), @as(i32, @intCast(height)));
                pos.y = @divFloor(@as(i32, @intCast(i)), @as(i32, @intCast(height)));
            }
            if (c != '\n' and c != '\r') {
                grid[i] = c;
                i += 1;
            }
        }

        if (grid[obj] != '.') {
            continue;
        }

        grid[obj] = '#';

        var dir = Vec2{ .x = 0, .y = -1 };
        const addDirToPos = struct {
            fn do(_pos: Vec2, _dir: Vec2, _w: usize, _h: usize) error{OutOfRange}!Vec2 {
                const next = Vec2{ .x = _pos.x + _dir.x, .y = _pos.y + _dir.y };
                if (next.x < 0 or next.x >= _w or next.y < 0 or next.y >= _h) {
                    return error.OutOfRange;
                }
                return next;
            }
        }.do;

        var count: i32 = 0;
        var steppedOnXInARow: i32 = 0;
        var isLoop = false;
        loop: while (true) {
            if (grid[pos.toIndex(height)] == 'X') {
                steppedOnXInARow += 1;
            } else {
                grid[pos.toIndex(height)] = 'X';
                count += 1;
                steppedOnXInARow = 0;
            }
            if (steppedOnXInARow == count) {
                isLoop = true;
                break;
            }
            var next = addDirToPos(pos, dir, width, height) catch break :loop;
            // std.debug.print("{any} => {any} {c} > {any}\n", .{ pos, next, grid[next.toIndex(height)], dir });
            while (grid[next.toIndex(height)] == '#') {
                const dir2 = .{ .x = -dir.y, .y = dir.x };
                dir = dir2;
                next = try addDirToPos(pos, dir, width, height);
            }
            pos = next;
        }

        // std.debug.print("obj {any} isloop:{any}\n\n", .{ obj, isLoop });
        if (isLoop) {
            locations += 1;
            // for (0..height) |y| {
            //     std.debug.print("{s}\n", .{grid[y * height .. y * height + width]});
            // }
        }
    }

    return locations;
}

pub fn calc(alloc: std.mem.Allocator) !void {
    std.debug.print("{d}\n", .{try calc1(alloc)});
    std.debug.print("{d}\n", .{try calc2(alloc)});
}
