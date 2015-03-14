RUSTC=rustc

LIBCORE_SRC ?= $(shell pwd)/opt/rust/src/libcore

O ?= build

ARCH=aarch64
include rt/$(ARCH)/Makefile.include
TARGET_FILE=rt/$(ARCH)/target.json

CC=$(CROSS_COMPILE)gcc
AR=$(CROSS_COMPILE)ar
AS=$(CROSS_COMPILE)as
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump

RSFLAGS += -O -g
CFLAGS += -O2

COMMON_FLAGS += -g
COMMON_FLAGS += -Wall -nostdlib

AFLAGS += -D__ASSEMBLY__ $(COMMON_FLAGS) -Ic/include
CFLAGS += $(COMMON_FLAGS) -Ic/include
LDFLAGS += $(COMMON_FLAGS)

RSFLAGS += --cfg arch_$(ARCH)
LDFLAGS +=
CFLAGS += -Irt/$(ARCH)/include/

.PHONY: all

all: $(O)/kernel.hex $(O)/kernel.bin

RS_SRCS := $(shell find src -name '*.rs')

RS_CPP_SRCS := $(shell find src -name '*.rs.cpp')
RS_CPP_OUTS := $(RS_CPP_SRCS:.rs.cpp=_auto.rs)

RT_SRCS=rt/$(ARCH)/head.S

RT_OBJS = $(RT_SRCS:.c=.o)
RT_OBJS := $(RT_OBJS:.S=.o)


RT_OBJS := $(addprefix $(O)/,$(RT_OBJS))

RT_OBJS_DEPS := $(RT_OBJS:.o=.o.d)
-include $(RT_OBJS_DEPS)

$(O)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@
	$(CC) $(CFLAGS) -MM -MT$@ -MF$@.d -c $< -o $@

$(O)/%.o: %.S
	mkdir -p $(dir $@)
	$(CC) $(AFLAGS) -c $< -o $@
	$(CC) $(AFLAGS) -MM -MT$@ -MF$@.d -c $<

%_auto.rs: %.rs.cpp
	$(CC) -E -P $< -o $@

$(O)/libcompiler-rt.a: $(RT_OBJS)
	mkdir -p $(dir $@)
	$(AR) rcs $@ $(RT_OBJS)

$(O)/libcore.rlib: $(LIBCORE_SRC)/lib.rs
	mkdir -p $(dir $@)
	$(RUSTC) --target $(TARGET_FILE) \
		$(RSFLAGS) \
		-C link-args="$(LDFLAGS)" -L. \
		-Z print-link-args --crate-type=rlib \
		$(LIBCORE_SRC)/lib.rs \
		-o $@

$(O)/kernel.elf: $(RS_SRCS) $(RS_CPP_OUTS) \
	$(O)/libcore.rlib $(O)/libcompiler-rt.a rt/$(ARCH)/kernel.ld
	$(RUSTC) --target $(TARGET_FILE) \
		$(RSFLAGS) \
		-A non_camel_case_types -A dead_code -A non_snake_case \
		-C link-args="$(LDFLAGS) -Trt/$(ARCH)/kernel.ld" -L$(O) -Z print-link-args \
		src/main.rs \
		-o $@

$(O)/kernel.hex: $(O)/kernel.elf
	$(OBJCOPY) -O ihex $(O)/kernel.elf $(O)/kernel.hex

$(O)/kernel.bin: $(O)/kernel.elf
	$(OBJCOPY) -O binary $(O)/kernel.elf $(O)/kernel.bin

.PHONY: clean
clean:
	rm -f $(RT_OBJS) $(RT_OBJS_DEPS) $(O)/*.a $(O)/kernel.* $(RS_CPP_OUTS)

.PHONY: cleanall
cleanall: clean
	rm -f $(O)/*.rlib

.PHONY: objdump
objdump:
	$(OBJDUMP) -D $(O)/kernel.elf

.PHONY: qemu
qemu: qemu-$(ARCH)

.PHONY: qemu-aarch64
qemu-aarch64:
	qemu-system-aarch64 -s -nographic -machine vexpress-a15 -cpu cortex-a57 -m 2048 -kernel $(O)/kernel.bin

.PHONY: qemu-gdb
qemu-gdb:
	$(CROSS_COMPILE)gdb -s $(O)/kernel -ex "target remote localhost:1234"

.PHONY: FORCE

