const std = @import("std");
const zl_debug = @import("./debug/zlox_debug.zig");
const Chunk = @import("./bytecode/chunk.zig").Chunk;
const OpCode = @import("./bytecode/opcodes.zig").OpCode;
const VirtualMachine = @import("./vm/vm.zig").VirtualMachine;

const debug = std.debug.print;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    var machine = VirtualMachine.init(allocator);
    defer machine.deinit();
    var chunk: Chunk = Chunk.init(allocator);
    defer chunk.deinit();
    // defer chunk.deinit();
    chunk.write_op_code(OpCode.op_return, 123);
    const name = "test_chunk";
    zl_debug.dissassemble_chunk(&chunk, name);
    _ = machine.interpret(&chunk) catch unreachable;
    std.process.exit(0);
}

test main {
    std.testing.refAllDecls(@This());
}
