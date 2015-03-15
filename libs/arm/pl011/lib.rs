#![no_std]
#![feature(no_std)]
#![feature(core)]

extern crate core;
extern crate titanium;

use titanium::io::{VolatileAccess, Default};
use titanium::drv;

const PL011_DR : usize = 0x000;
const PL011_CR : usize = 0x0c0;

pub struct PL011<A = Default>
where A : VolatileAccess {
    base : usize,
    _access : A,
}

impl PL011 {
    pub fn new(base : usize) -> PL011 {
        PL011 {
            base: base,
            _access: Default,
        }
    }
}

impl<A> drv::Driver for PL011<A>
where A : VolatileAccess
{
    fn init(&mut self) {
        A::write_u16(self.base + PL011_CR, 1 << 0 | 1 << 8);
    }
}

impl<A> drv::Uart for PL011<A>
where A : VolatileAccess
{
    fn put(&mut self, ch : u8) {
        A::write_u8(self.base + PL011_DR, ch)
    }
}
