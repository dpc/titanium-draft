pub mod uart;

pub use self::uart::Uart;

pub trait Driver {
    fn init(&mut self);
}
