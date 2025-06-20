const std = @import("std");
const show = @import("show.zig");

pub fn main() !void {
    const Option = enum {
        show,
        showconf,
        set,
        setconf,
        addconf,
        syncconf,
        genkey,
        genpsk,
        pubkey,
    };

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    _ = args.next() orelse "wg-zig";

    while (args.next()) |arg| {
        const option = std.meta.stringToEnum(Option, arg) orelse {
            std.debug.print("{s} is not a valid argument\n", .{arg});
            return;
        };
        switch (option) {
            .show => {
                try show.show_main(allocator) orelse return;
            },
            else => {
                std.log.err("option \x1b[31m{s}\x1b[0m is not supported", .{@tagName(option)});
                return;
            },
        }
    }
}
