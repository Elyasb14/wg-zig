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
        if (std.mem.startsWith(u8, name, "utun")) {
            std.debug.print("Interface: {s}\n", .{name});
        }

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

const WGIFInfo = struct {
    path: []const u8,
    contents: []const u8,

    pub fn init(path: []const u8, contents: []const u8) WGIFInfo {
        return .{ .path = path, .contents = contents };
    }
};

fn get_wg_configs(alloc: std.mem.Allocator) ![]WGIFInfo {
    const tag = builtin.target.os.tag;

    var files = std.ArrayList(WGIFInfo).init(alloc);
    defer files.deinit();

    const path = switch (tag) {
        .macos => "/opt/homebrew/etc/wireguard",
        .linux => "/etc/wireguard",
        else => return error.UnsupportedOS,
    };

    const dir = try std.fs.openDirAbsolute(path, .{ .iterate = true });
    var it = dir.iterate();

    while (try it.next()) |entry| {
        if (std.mem.endsWith(u8, entry.name, ".conf")) {
            const full_path = try std.fs.path.join(alloc, &[_][]const u8{ path, entry.name });

            const contents = try dir.readFileAlloc(alloc, entry.name, std.math.maxInt(usize));
            const wfif = WGIFInfo.init(full_path, contents);
            try files.append(wfif);
        }
    }

    return try files.toOwnedSlice();
}
pub fn show_main(alloc: std.mem.Allocator) void {
    const configs = get_wg_configs(alloc) catch |err| {
        std.debug.print("ERROR: {any}\n", .{err});
        return;
    };
    get_netif();

    for (configs) |config| {
        std.debug.print("path: {s}\n", .{config.path});
        std.debug.print("contents: {s}\n", .{config.contents});
    }
}
