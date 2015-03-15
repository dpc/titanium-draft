LIBCORE_SRC ?= $(shell pwd)/opt/rust/src/libcore

O ?= $(shell pwd)/build

include titanium/Makefile.common

AFLAGS += -D__ASSEMBLY__ $(COMMON_FLAGS) -Ic/include

.PHONY: all

all: $(O)/kernel.hex $(O)/kernel.bin

RS_SRCS := $(shell find src -name '*.rs')
RT_SRCS=rt/$(ARCH)/head.S

RT_OBJS = $(RT_SRCS:.c=.o)
RT_OBJS := $(RT_OBJS:.S=.o)

LIBS := $(shell find libs -name 'Makefile')

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

$(TARGET_FILE): titanium/src/arch/$(ARCH)/target.json
	mkdir -p $(O)
	cp -f $< $@

$(O)/libcompiler-rt.a: $(RT_OBJS) $(TARGET_FILE)
	mkdir -p $(dir $@)
	$(AR) rcs $@ $(RT_OBJS)

$(O)/libcore.rlib: $(LIBCORE_SRC)/lib.rs $(TARGET_FILE)
	mkdir -p $(dir $@)
	$(RUSTC) --target $(TARGET_FILE) \
		$(RSFLAGS) \
		-C link-args="$(LDFLAGS)" -L. \
		-Z print-link-args --crate-type=rlib \
		$(LIBCORE_SRC)/lib.rs \
		-o $@

$(O)/libtitanium.rlib: $(O)/libcore.rlib $(TARGET_FILE) FORCE
	cd titanium; make O=$(O)

$(LIBS): FORCE
	cd $(dir $@) && make O=$(O) TARGET_FILE=$(TARGET_FILE)

# libtitanium added manualy to resovle static library linking ordering issues
$(O)/kernel.elf: $(RS_SRCS) $(O)/libtitanium.rlib $(LIBS) \
	$(O)/libcore.rlib $(O)/libcompiler-rt.a rt/$(ARCH)/kernel.ld
	$(RUSTC) --target $(TARGET_FILE) \
		$(RSFLAGS) \
		-A non_camel_case_types -A dead_code -A non_snake_case \
		-C link-args="$(LDFLAGS) -Trt/$(ARCH)/kernel.ld $(O)/libtitanium.rlib" -L$(O) -Z print-link-args \
		src/main.rs \
		-o $@

$(O)/kernel.hex: $(O)/kernel.elf
	$(OBJCOPY) -O ihex $(O)/kernel.elf $(O)/kernel.hex

$(O)/kernel.bin: $(O)/kernel.elf
	$(OBJCOPY) -O binary $(O)/kernel.elf $(O)/kernel.bin

.PHONY: clean
clean:
	echo 'Use `make fullclean` for a full cleaning'
	cd titanium && make clean
	rm -f $(RT_OBJS) $(RT_OBJS_DEPS) $(O)/*.a $(O)/kernel.* $(RS_CPP_OUTS)

.PHONY: fullclean
fullclean: clean
	rm -f $(O)/*.rlib

.PHONY: objdump
objdump:
	$(OBJDUMP) -D $(O)/kernel.elf

.PHONY: run
run: qemu

.PHONY: qemu
qemu: qemu-$(ARCH)

.PHONY: qemu-aarch64
qemu-aarch64:
	qemu-system-aarch64 -nographic -machine vexpress-a15 -cpu cortex-a57 -m 2048 -kernel $(O)/kernel.bin

.PHONY: qemu-gdb
qemu-gdb:
	$(CROSS_COMPILE)gdb -s $(O)/kernel -ex "target remote localhost:1234"

.PHONY: FORCE

