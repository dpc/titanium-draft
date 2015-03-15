//! Convenient macro to read a CPU register

/// read from CPU register using MRS instruction
#[macro_export]
macro_rules! reg32_read {
    ( $reg:ident ) => {
        {
            let mut val : u32;
            unsafe {
                asm!(concat!("mrs $0, ", stringify!($reg))
                     : "=r"(val)
                    );
            }

            val
        }
    }
}

/// read from CPU register using MRS instruction
#[macro_export]
macro_rules! reg64_read {
    ( $reg:ident ) => {
        {
            let mut val : u64;
            unsafe {
                asm!(concat!("mrs $0, ", stringify!($reg))
                     : "=r"(val)
                    );
            }

            val
        }
    }
}

/// write to a CPU register using MSR instruction
#[macro_export]
macro_rules! reg32_write {
    ( $reg:ident, $val:expr ) => {
        {
            let val : u32 = $val;
            unsafe {
                asm!(concat!("msr ", stringify!($reg), "$0" )
                     :
                     : "r"(val)
                    );
            }
        }
    }
}

/// write to a CPU register using MSR instruction
#[macro_export]
macro_rules! reg64_write {
    ( $reg:ident, $val:expr ) => {
        {
            let val : u64 = $val;
            unsafe {
                asm!(concat!("msr ", stringify!($reg), "$0" )
                     :
                     : "r"(val)
                    );
            }
        }
    }
}

/// dsb instruction
#[macro_export]
macro_rules! dsb {
    () => {
        {
            unsafe {
                asm!(concat!("dsb"));
            }
        }
    }
}

/// dmb instruction
#[macro_export]
macro_rules! dmb {
    () => {
        {
            unsafe {
                asm!(concat!("dmb"));
            }
        }
    }
}

/// isb instruction
#[macro_export]
macro_rules! isb {
    () => {
        {
            unsafe {
                asm!(concat!("isb"));
            }
        }
    }
}
