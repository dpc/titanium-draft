
mod consts_auto;

use self::consts_auto::*;

pub const NAME : &'static str = "aarch64";

pub fn cpu_id() -> u8 {
    let mut reg : u64;
    unsafe {
        asm!("mrs $0, mpidr_el1"
          : "=r"(reg)
          );
    }

    (reg & MPIDR_AFF0_MASK) as u8
}
