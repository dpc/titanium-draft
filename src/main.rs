#![no_std]
#![no_main]
#![feature(lang_items)]
#![feature(no_std)]
#![feature(core)]
#![feature(asm)]

#![crate_name="kernel"]

extern crate core;

mod rust;

mod arch;
mod mem;


use core::intrinsics::{volatile_store, volatile_load};

static mut x : u32 = 0;

#[no_mangle]
pub extern "C" fn main()
{
    if arch::cpu_id() == 0 {
        mem::init();
    }

    loop {
        let mut tx = unsafe { volatile_load(&mut x) };
        tx += 1;
        unsafe { volatile_store(&mut x,  tx ); }
    }
}

