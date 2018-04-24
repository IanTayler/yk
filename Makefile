ARCH ?= x86_64
VERSION := 0.0.0
KERNELNAME := yk-$(VERSION)-$(ARCH)

OSNAME := Carozo-$(VERSION)-$(ARCH)

BASEBUILD := build
OBJDIR := $(BASEBUILD)/objdir
ISODIR := $(BASEBUILD)/iso

CC := clang
# Fix -march to be handled automatically.
CFLAGS := --target=$(ARCH)-elf -march=x86-64 -ffreestanding -c

ASM_SRCDIR := src/asm/$(ARCH)
C_SRCDIR := src/
C_INCLUDE := src/include

ASM_SOURCES := $(wildcard $(ASM_SRCDIR)/*.s)
C_SOURCES := $(wildcard $(C_SRCDIR)/*.c)

ALL_SOURCES := $(ASM_SOURCES) $(C_SOURCES)

ASM_OBJECTS := $(patsubst $(ASM_SRCDIR)/%.s, $(OBJDIR)/asm/%.o, \
	$(ASM_SOURCES))
C_OBJECTS := $(patsubst $(C_SRCDIR)/%.c, $(OBJDIR)/c/%.o, \
	$(C_SOURCES))
ALL_OBJECTS := $(ASM_OBJECTS) $(C_OBJECTS)

KERNEL := $(BASEBUILD)/$(KERNELNAME).bin
ISO := $(BASEBUILD)/$(OSNAME).iso

linkscript := cfg/link.ld
grubcfg := cfg/grub.cfg

LD := ld
LDFLAGS := -n -T $(linkscript)

.PHONY: all clean iso run

all: $(KERNEL)

run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO)

$(KERNEL): $(linkscript) $(ALL_OBJECTS)
	mkdir -p $(ISODIR)
	$(LD) $(LDFLAGS) -o $(KERNEL) $(ALL_OBJECTS)

iso: $(ISO)

$(ISO): $(KERNEL) $(grubcfg)
	mkdir -p $(ISODIR)/boot/grub
	cp $(grubcfg) $(ISODIR)/boot/grub
	cp $(KERNEL) $(ISODIR)/boot/yk.bin
	grub-mkrescue -o $(ISO) $(ISODIR)

clean:
	rm -r build

$(OBJDIR)/asm/%.o: $(ASM_SRCDIR)/%.s
	mkdir -p $(shell dirname $@)
	$(CC) $(CFLAGS) $< -o $@

$(OBJDIR)/c/%.o: $(C_SRCDIR)/%.c
	mkdir -p $(shell dirname $@)
	$(CC) $(CFLAGS) $< -o $@ -I$(C_INCLUDE)
