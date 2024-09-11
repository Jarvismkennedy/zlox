const std = @import("std");
const zl_debug = @import("./debug/zlox_debug.zig");
const Chunk = @import("./bytecode/chunk.zig").Chunk;
const OpCode = @import("./bytecode/opcodes.zig").Code;
const debug = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    var chunk: Chunk = try Chunk.init(allocator);
    defer chunk.deinit();
    try chunk.write_byte_code(OpCode.op_return);
    const name = "test_chunk";
    zl_debug.dissassemble_chunk(&chunk, name);

    std.process.exit(0);
}

test "simple test" {
    var chunk: Chunk = Chunk.init(allocator);
    defer {
        // chunk.deinit();
    }
    try chunk.write_byte_code(OpCode.op_return);
    const name = "test_chunk";
    zl_debug.dissassemble_chunk(&chunk, name);
    const actual = chunk.byte_code.items[0];
    try std.testing.expect(actual == OpCode.op_return);
}

test "complext_test" {
    var w = wrap.init(std.testing.allocator);
    try w.add(42);
}

const wrap = struct {
    array_list: std.ArrayList(i32),
    allocator: std.mem.Allocator,
    pub fn init(ally: std.mem.Allocator) wrap {
        return wrap{
            .array_list = std.ArrayList(i32).init(ally),
            .allocator = ally,
        };
    }
    pub fn add(self: *wrap, i: i32) !void {
        try self.array_list.append(i);
    }
    pub fn deinit(self: *wrap) !void {
        self.array_list.deinit();
    }
};
