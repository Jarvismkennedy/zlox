const std = @import("std");
const assert = std.debug.assert;

pub const VirtualMachine = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) VirtualMachine {
        return VirtualMachine{ .allocator = allocator };
    }

    pub fn deinit(self: *VirtualMachine) void {
        _ = self;
    }
};
