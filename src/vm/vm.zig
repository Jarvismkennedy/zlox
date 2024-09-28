const std = @import("std");
const Chunk = @import("../bytecode/chunk.zig").Chunk;
const OpCode = @import("../bytecode/opcodes.zig").OpCode;
const ByteCode = @import("../bytecode/chunk.zig").ByteCode;
const assert = std.debug.assert;

pub const InterpreterError = error{ CompileError, RuntimeError };
pub const InterpreterResult = enum { Ok };

pub const VirtualMachine = struct {
    allocator: std.mem.Allocator,
    chunk: *Chunk = undefined,
    ip: [*]ByteCode = undefined,
    pub fn init(allocator: std.mem.Allocator) VirtualMachine {
        return VirtualMachine{ .allocator = allocator };
    }
    pub fn deinit(self: *VirtualMachine) void {
        _ = self;
    }

    pub fn interpret(self: *VirtualMachine, chunk: *Chunk) InterpreterError!InterpreterResult {
        self.chunk = chunk;
        self.ip = chunk.byte_code_array.items.ptr;
        return self.run();
    }
    fn run(self: *VirtualMachine) InterpreterError!InterpreterResult {
        while (true) {
            const instruction: ByteCode = self.read_byte();
            switch (instruction) {
                @intFromEnum(OpCode.op_return) => return .Ok,
                else => unreachable,
            }
        }
    }
    fn read_byte(self: *VirtualMachine) ByteCode {
        defer self.ip += 1;
        return self.ip[0];
    }
};

test VirtualMachine {
    var chunk = Chunk.init(std.testing.allocator);
    defer chunk.deinit();
    chunk.write_op_code(OpCode.op_return, 0);
    var vm = VirtualMachine.init(std.testing.allocator);
    defer vm.deinit();

    const t = try vm.interpret(&chunk);
    try std.testing.expectEqual(.Ok, t);
}
