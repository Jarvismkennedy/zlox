const std = @import("std");
const ValueType = @import("./values.zig").ValueType;
const OpCode = @import("./opcodes.zig").Code;
const Allocator = std.mem.Allocator;
const ByteCodeArrayList = std.ArrayList(OpCode);
const ValueArrayList = std.ArrayList(ValueType);

pub const Chunk = struct {
    byte_code: ByteCodeArrayList,
    value_array: ValueArrayList,
    allocator: Allocator,

    pub fn init(allocator: Allocator) Chunk {
        const chunk: Chunk = .{
            .allocator = allocator,
            .byte_code = ByteCodeArrayList.init(allocator),
            .value_array = ValueArrayList.init(allocator),
        };
        return chunk;
    }
    pub fn deinit(self: *Chunk) void {
        self.byte_code.deinit();
        self.value_array.deinit();
    }
    pub fn write_byte_code(self: *Chunk, byte: OpCode) Allocator.Error!void {
        try self.byte_code.append(byte);
    }
    pub fn add_const(self: *Chunk, value: ValueType) Allocator.Error!usize {
        try self.value_array.append(value);
        return self.value_array.items.len;
    }
};
