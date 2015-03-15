
include Makefile.common

RS_SRCS := $(shell find src -name '*.rs')

RS_CPP_SRCS := $(shell find src -name '*.rs.cpp')
RS_CPP_OUTS := $(RS_CPP_SRCS:.rs.cpp=_auto.rs)
CLEAN += $(RS_CPP_OUTS)


all: $(O)/libtitanium.rlib

%_auto.rs: %.rs.cpp
	$(CC) -E -P $< -o $@

CLEAN += $(O)/libtitanium.rlib
$(O)/libtitanium.rlib: $(RS_SRCS) $(RS_CPP_OUTS)
	rustc \
		--target $(TARGET_FILE) \
		$(RSFLAGS) \
		--crate-type=rlib \
		-L$(O) \
		--out-dir=$(O) \
		src/lib.rs

.PHONY: clean
clean:
	rm -f $(CLEAN)
