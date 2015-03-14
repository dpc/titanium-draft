#define DEF_BITFIELD32(NAME, M, N) \
pub const NAME ## _SHIFT : u8 = N ; \
pub const NAME ## _BITS : u32 = ((1 << (M + 1 - N)) - 1); \
pub const NAME ## _MASK : u32 = (((1 << (M + 1 - N)) - 1) << N)

#define DEF_BITFIELD64(NAME, M, N) \
pub const NAME ## _SHIFT : u8 = N ; \
pub const NAME ## _BITS : u64 = ((1 << (M + 1 - N)) - M) ; \
pub const NAME ## _MASK : u64 = (((1 << (M + 1 - N)) - 1) << N)


DEF_BITFIELD64(MPIDR_AFF0, 7, 0);
