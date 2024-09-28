const std = @import("std");
const ValueType = @import("./values.zig").ValueType;
const OpCode = @import("./opcodes.zig").OpCode;
const Allocator = std.mem.Allocator;

pub const ByteCode = u8;
pub const LineSize = u64;

pub const ByteCodeArrayList = std.ArrayList(ByteCode);
pub const LineArrayList = std.ArrayList(LineSize);
pub const ValueArrayList = std.ArrayList(ValueType);

const zl_debug = @import("../debug/zlox_debug.zig");

pub const Chunk = struct {
    byte_code_array: ByteCodeArrayList,
    lines_array: LineArrayList,
    value_array: ValueArrayList,

    allocator: Allocator,

    pub fn init(allocator: Allocator) Chunk {
        const chunk: Chunk = .{
            .allocator = allocator,
            .byte_code_array = ByteCodeArrayList.init(allocator),
            .value_array = ValueArrayList.init(allocator),
            .lines_array = LineArrayList.init(allocator),
        };
        return chunk;
    }
    pub fn deinit(self: *Chunk) void {
        self.byte_code_array.deinit();
        self.value_array.deinit();
        self.lines_array.deinit();
    }
    pub fn write_op_code(self: *Chunk, byte: OpCode, line: LineSize) void {
        self.byte_code_array.append(@as(ByteCode, @intFromEnum(byte))) catch unreachable;
        self.lines_array.append(line) catch unreachable;
    }
    pub fn byte_code_at(self: *Chunk, offset: usize) ByteCode {
        std.debug.assert(offset < self.byte_code_array.items.len);
        return self.byte_code_array.items[offset];
    }
    pub fn value_at(self: *Chunk, offset: usize) ValueType {
        std.debug.assert(offset < self.value_array.items.len);
        return self.value_array.items[offset];
    }
    pub fn write_constant(self: *Chunk, byte: ValueType, line: LineSize) void {
        self.write_op_code(OpCode.op_constant, line);
        const const_offset = self.add_const(byte);
        self.write_constant_byte_code(const_offset, line);
    }

    /// We can only store 256 constants per chunk currently because the index into the values array is stored in the
    /// byte_code_array ([]u8)
    fn write_constant_byte_code(self: *Chunk, offset: usize, line: LineSize) void {
        std.debug.assert(offset < @sizeOf(ByteCode));
        self.byte_code_array.append(@intCast(offset)) catch unreachable;
        self.lines_array.append(line) catch unreachable;
    }
    fn add_const(self: *Chunk, value: ValueType) ByteCode {
        self.value_array.append(value) catch unreachable;
        std.debug.assert(self.value_array.items.len <= @sizeOf(ByteCode));
        return @intCast(self.value_array.items.len - 1);
    }

    // RLE to save space
    fn write_line(self: *Chunk, line: LineSize) void {
        if (self.lines_array.items.len >= 2 and line == self.lines_array.items[self.lines_array.items.len - 2]) {
            self.lines_array.items[self.lines_array.items.len - 1] += 1;
            return;
        }
        self.lines_array.appendSlice(.{ line, 0 });
    }
    pub fn get_line_number_of_byte(self: *Chunk, byte_code_offset: usize) usize {
        std.debug.assert(self.lines_array.items.len >= 2);
        var count: usize = byte_code_offset;
        var line_number_offset: usize = 0;
        while (count > 0) {
            if (count > self.lines_array.items[line_number_offset]) {
                count -= self.lines_array.items[line_number_offset];
            } else {
                break;
            }
            line_number_offset += 2;
        }
        std.debug.assert(self.lines_array.items.len > line_number_offset);
        return self.lines_array.items[line_number_offset];
    }
};

test Chunk {
    var chunk: Chunk = Chunk.init(std.testing.allocator);
    defer chunk.deinit();
    const line = 1234560;
    chunk.write_constant(1.2, line);
    chunk.write_op_code(OpCode.op_return, line);
    const name = "test_chunk";
    zl_debug.dissassemble_chunk(&chunk, name);
}

test "get_line_number" {
    var chunk: Chunk = Chunk.init(std.testing.allocator);
    defer chunk.deinit();
    const line = 1;
    chunk.write_constant(1.2, line);
    chunk.write_op_code(OpCode.op_return, line + 1);
    try std.testing.expectEqual(chunk.get_line_number_of_byte(0), 1);
    try std.testing.expectEqual(chunk.get_line_number_of_byte(1), 1);
    try std.testing.expectEqual(chunk.get_line_number_of_byte(2), 2);
}
