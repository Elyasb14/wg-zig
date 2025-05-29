const std = @import("std");

//     while (args.next()) |arg| {
//         const option = std.meta.stringToEnum(Option, arg) orelse {
//             std.debug.print("{s} is not a valid argument\n", .{arg});
//             help(process_name);
//         };
//
//         switch (option) {
//             .@"--address" => {
//                 address = args.next() orelse {
//                     std.debug.print("--address provided with no argument\n", .{});
//                     help(process_name);
//                 };
//             },
//             .@"--port" => {
//                 const port_s = args.next() orelse {
//                     std.debug.print("--port provided with no argument\n", .{});
//                     help(process_name);
//                 };
//                 port = std.fmt.parseInt(u16, port_s, 10) catch {
//                     std.debug.print("--port argument is not a valid u16\n", .{});
//                     help(process_name);
//                 };
//             },
//             .@"--help" => help(process_name),
//         }
//     }
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
            .show => {},
            else => {
                std.log.err("option \x1b[31m{s}\x1b[0m is not supported", .{@tagName(option)});
                return;
            },
        }
    }
}
