pub const Code = enum {
    op_return,
};

pub fn get_instuction(byte: Code) []const u8 {
    return @tagName(byte);
}
