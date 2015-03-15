#![feature(no_std)]
#![feature(core)]
#![feature(lang_items)]
#![feature(asm)]
#![no_std]

#![feature(trace_macros)]

#![crate_name="titanium"]

extern crate core;

pub mod lang;
pub mod io;
pub mod drv;
pub mod consts;

#[macro_use]
pub mod arch;

#[test]
fn it_works() {
}
