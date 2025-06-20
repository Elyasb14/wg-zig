const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("ifaddrs.h");
    @cInclude("sys/types.h");
    @cInclude("sys/socket.h");
    @cInclude("netinet/in.h");
    @cInclude("arpa/inet.h");
    @cInclude("net/if.h");
});

fn get_wg_files(alloc: std.mem.Allocator) !?[][]const u8 {
    const tag = builtin.target.os.tag;

    var buf = std.ArrayList([]const u8).init(alloc);
    defer buf.deinit();

    switch (tag) {
        .macos => {
            const dir = try std.fs.openDirAbsolute("/opt/homebrew/etc/wireguard", .{ .iterate = true });
            var it = dir.iterate();
            while (try it.next()) |x| {
                if (std.mem.endsWith(u8, x.name, ".conf")) try buf.append(x.name);
            }
            return try buf.toOwnedSlice();
        },
        .linux => {
            const dir = try std.fs.openDirAbsolute("/etc/wireguard", .{ .iterate = true });
            var it = dir.iterate();
            while (try it.next()) |x| {
                if (std.mem.endsWith(u8, x.name, ".conf")) try buf.append(x.name);
            }
            return try buf.toOwnedSlice();
        },
        else => {
            std.debug.print("we don't support OS: {s}", .{@tagName(tag)});
            return null;
        },
    }
}

fn get_netif() void {
    var ifap: ?*c.struct_ifaddrs = null;
    if (c.getifaddrs(&ifap) != 0) {
        std.debug.print("getifaddrs failed\n", .{});
        return;
    }

    var ifa = ifap;
    while (ifa) |ifa_ptr| {
        if (ifa_ptr.ifa_addr == null) {
            ifa = ifa_ptr.ifa_next;
            continue;
        }

        const family = ifa_ptr.ifa_addr.*.sa_family;
        const name = std.mem.sliceTo(ifa_ptr.ifa_name, 0);
        std.debug.print("Interface: {s}\n", .{name});

        if (family == c.AF_INET) {
            const addr_in: *const c.struct_sockaddr_in = @alignCast(@ptrCast(ifa_ptr.ifa_addr));
            var buf: [c.INET_ADDRSTRLEN]u8 = undefined;
            const ip = c.inet_ntop(c.AF_INET, &addr_in.sin_addr, &buf, buf.len);
            if (ip != null)
                std.debug.print("IPv4: {s}\n", .{std.mem.sliceTo(ip, 0)});
        }
        ifa = ifa_ptr.ifa_next;
    }

    c.freeifaddrs(ifap);
}

pub fn show_main(alloc: std.mem.Allocator) !?void {
    const wg_paths = try get_wg_files(alloc) orelse return null;


}
