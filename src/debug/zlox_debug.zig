const std = @import("std");
const Chunk = @import("../bytecode/chunk.zig").Chunk;
const OpCode = @import("../bytecode/opcodes.zig");

pub fn dissassemble_chunk(chunk: *Chunk, name: []const u8) void {
    std.debug.print("== {s} ==\n", .{ .name = name });
    for (chunk.byte_code.items, 0..) |item, i| {
        const instruction = OpCode.get_instuction(item);
        std.debug.print("{b:0>4} {s}\n", .{ .idx = i, .name = instruction });
    }
}
