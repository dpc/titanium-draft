# Titanium

Titanium is an exercise in writing a kernel in Rust programming language.


Immediate goal is to complete basic functionality targeting ARMv8 (aarch64)
and Vexpress board emulated by Qemu as a testing platform.

Everything is developed in Linux.

See [status page](//github.com/dpc/titanium/wiki/Status) for project status.

## Building

Follow `.travis.yml` to understand how to set up toolchain and external requirements.

Aftwards:

* `make` builds everything
* `make qemu` to start the kernel inside Qemu

## Design

Components:

* `titanium/`: collection of low-level macros, functions and constants that
  can be reused by other software targeting bare-metal development in Rust
* `rt/`: basic runtime necessary for things to compile
* `libs/`: each crate is separate driver, built as a separate crate
* `src/`: initial kernel using `tianium/` and `libs/`
* `c/`: some C code glue


