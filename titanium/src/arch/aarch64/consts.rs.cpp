#define DEF_BITFIELD32(NAME, M, N) \
pub const NAME ## _SHIFT : u8 = N ; \
pub const NAME ## _BITS : u32 = ((1 << (M + 1 - N)) - 1); \
pub const NAME ## _MASK : u32 = (((1 << (M + 1 - N)) - 1) << N)

#define DEF_BITFIELD64(NAME, M, N) \
pub const NAME ## _SHIFT : u8 = N ; \
pub const NAME ## _BITS : u64 = ((1 << (M + 1 - N)) - M) ; \
pub const NAME ## _MASK : u64 = (((1 << (M + 1 - N)) - 1) << N)


DEF_BITFIELD64(MPIDR_AFF0, 7, 0);

DEF_BITFIELD64(PTE_TYPE, 1, 0);
pub const PTE_TYPE_INVALID : u64 = 0x0;
pub const PTE_TYPE_BLOCK : u64 = 0x1;
pub const PTE_TYPE_TABLE : u64 = 0x3;

DEF_BITFIELD64(PTE_LATTRS, 11, 2);
DEF_BITFIELD64(PTE_ADDR, 47, 12);
DEF_BITFIELD64(PTE_HATTRS, 63, 52);

DEF_BITFIELD64(PTE_XN, 54, 54);
DEF_BITFIELD64(PTE_NG, 11, 11);
DEF_BITFIELD64(PTE_SH, 9, 8);
DEF_BITFIELD64(PTE_AP, 7, 6);
pub const PTE_AP_KERNEL : u64 = 0x0;
pub const PTE_AP_RW: u64 = 0x1;
pub const PTE_AP_KERNEL_RO: u64 = 0x2;
pub const PTE_AP_RO: u64 = 0x3;

DEF_BITFIELD64(PTE_NS, 5, 5);
DEF_BITFIELD64(PTE_ATTRINDX, 4, 2);

DEF_BITFIELD64(TTBR_BADDR, 47, 0);
DEF_BITFIELD64(TTBR_ASID, 63, 48);
