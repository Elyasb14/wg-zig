const std = @import("std");


// pub fn parse(allocator: std.mem.Allocator) !{
//     var args = try std.process.argsWithAllocator(allocator);
//     const process_name = args.next() orelse "tinyweather-node";
//
//     var port: u16 = 8080;
//     if (std.mem.endsWith(u8, process_name, "tinyweather")) {
//         port = 8081;
//     }
//
//     var address: []const u8 = "127.0.0.1";
//
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
//     return .{
//         .address = address,
//         .port = port,
//         .it = args,
//     };
// }
pub fn main() !void {

    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    const process_name = args.next() orelse "wg-zig";

}
