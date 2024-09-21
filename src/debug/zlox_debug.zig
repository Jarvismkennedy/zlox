const std = @import("std");
const Chunk = @import("../bytecode/chunk.zig").Chunk;
const OpCode = @import("../bytecode/opcodes.zig").OpCode;
const print = std.debug.print;

pub fn dissassemble_chunk(chunk: *Chunk, name: []const u8) void {
    std.debug.print("== {s} ==\n", .{ .name = name });
    var offset: usize = 0;
    while (offset < chunk.byte_code_array.items.len) {
        offset = dissassemble_instuction(chunk, offset);
    }
}

fn dissassemble_instuction(chunk: *Chunk, offset: usize) usize {
    print("{d:0>4} ", .{offset});
    if (offset > 0 and chunk.get_line_number_of_byte(offset) == chunk.get_line_number_of_byte(offset - 1)) {
        print("   | ", .{});
    } else {
        print("{d:0>4} ", .{chunk.get_line_number_of_byte(offset)});
    }

    const instruction = chunk.byte_code_at(offset);
    return switch (instruction) {
        @intFromEnum(OpCode.op_return) => simple_instruction(@tagName(OpCode.op_return), offset),
        @intFromEnum(OpCode.op_constant) => constant_instruction(chunk, @tagName(OpCode.op_constant), offset),
        else => unreachable,
    };
}

fn simple_instruction(name: []const u8, offset: usize) usize {
    print("{s}\n", .{name});
    return offset + 1;
}
fn constant_instruction(chunk: *Chunk, name: []const u8, offset: usize) usize {
    const const_offset = chunk.byte_code_at(offset + 1);
    print("{s:>4}", .{name});
    print("{d:>4}    '{d}'\n", .{ const_offset, chunk.value_at(const_offset) });
    return offset + 2;
}
