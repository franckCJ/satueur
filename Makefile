#===============================================================================
#
# main Makefile for satueur kernel
#
#===============================================================================

#-------------------------------------------------------------------------------
# target, cross-compiler, flags, ...
#-------------------------------------------------------------------------------
OS_NAME=satueur
OS_BIN=$(OS_NAME).bin
OS_ISO=$(OS_NAME).iso

TARGET=i686-elf

AS=$(TARGET)-as
CXX=$(TARGET)-g++
CC=$(TARGET)-gcc

CXXFLAGS= -std=c++11 -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
CFLAGS= -std=c11 -ffreestanding -O2 -Wall -Wextra
CPPFLAGS= -I kernel -I lib/libc/include
LDFLAGS= -lgcc

ifdef STR_AUTOTEST
CXXFLAGS += -DSTR_AUTOTEST
endif

objects=
linker=

TMPDIR:=$(shell mktemp -d /tmp/$(OS_NAME).XXXXX)

#-------------------------------------------------------------------------------
# includes
#-------------------------------------------------------------------------------
# tools
include scripts/utils.mk

# kernel core
include kernel/Makefile
include lib/Makefile

#-------------------------------------------------------------------------------
# compile rules
#-------------------------------------------------------------------------------
all: $(OS_BIN)

$(OS_BIN): $(objects)
	$(CXX) -T $(linker) -o $(OS_BIN) -ffreestanding -O2 \
		-nostdlib $(objects) $(LDFLAGS)
%.o: %.s
	$(AS) $^ -o $@

%.o: %.c
	$(CC) -c $^ -o $@ $(CPPFLAGS) $(CFLAGS)

%.o: %.cpp
	$(CXX) -c $^ -o $@ $(CPPFLAGS) $(CXXFLAGS)

#-------------------------------------------------------------------------------
# doc
#-------------------------------------------------------------------------------
doc:
	a2x README

#-------------------------------------------------------------------------------
# iso
#-------------------------------------------------------------------------------
iso: all
	@mkdir -p $(TMPDIR)/boot/grub 
	@cp $(OS_BIN) $(TMPDIR)/boot/$(OS_BIN)
	@touch $(TMPDIR)/boot/grub/grub.cfg
	@echo "menuentry \"satueur\" {\n		multiboot /boot/satueur.bin\n}" > \
		$(TMPDIR)/boot/grub/grub.cfg
	@grub-mkrescue -o $(OS_ISO) $(TMPDIR)
	@rm -rf $(TMPDIR)

#-------------------------------------------------------------------------------
# clean rules
#-------------------------------------------------------------------------------
clean-doc:
	rm -f README.pdf

clean-iso:
	rm -rf isodir
	rm -f satueur.iso

clean: clean-iso clean-doc
	find . -name *.o | xargs rm -f
	rm -f $(OS_BIN)