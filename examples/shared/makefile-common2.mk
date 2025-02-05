SDCARD_MOUNT_PATH ?= /Volumes/BAREAPP

LINKSCR ?= linkscript.ld
EXTLIBDIR ?= ../../third-party
UBOOTDIR ?= $(EXTLIBDIR)/u-boot/build
BUILDDIR ?= build
BINARYNAME ?= main
UIMAGENAME ?= $(BUILDDIR)/a7-main.uimg

OBJDIR = $(BUILDDIR)/obj/obj
LOADADDR 	= 0xC2000040
ENTRYPOINT 	= 0xC2000040

OBJECTS   = $(addprefix $(OBJDIR)/, $(addsuffix .o, $(basename $(SOURCES))))
DEPS   	  = $(addprefix $(OBJDIR)/, $(addsuffix .d, $(basename $(SOURCES))))

MCU ?=   -march=armv7-a+neon-vfpv4 -mfpu=neon -mfloat-abi=hard

ARCH_CFLAGS ?= -DUSE_FULL_LL_DRIVER \
			   -DSTM32MP157Cxx \
			   -DSTM32MP1 \
			   -DCORE_CA7 \

OPTFLAG ?= -O0

AFLAGS = $(MCU)

DSPFLAGS = -DARM_MATH_DSP=1 \
			-DARM_DSP_CONFIG_TABLES \
			-DARM_FFT_ALLOW_TABLES \
			-DARM_TABLE_BITREVIDX_FLT_32 \
			-DARM_TABLE_TWIDDLECOEF_RFFT_F32_64 \
			-DARM_TABLE_TWIDDLECOEF_F32_32 \
			-DARM_TABLE_SIN_F32 \
			-DARM_FAST_ALLOW_TABLES \

CFLAGS = -ggdb \
		 -fno-common \
		 $(ARCH_CFLAGS) \
		 $(DSPFLAGS) \
		 $(MCU) \
		 $(INCLUDES) \
		 -fdata-sections -ffunction-sections \
		 -ffast-math \
		 -ftree-vectorize \
		 -nostartfiles \
		 $(EXTRACFLAGS)\
		 -mtune=cortex-a7\

CXXFLAGS = $(CFLAGS) \
		-std=c++2a \
		-fno-rtti \
		-fno-exceptions \
		-fno-unwind-tables \
		-ffreestanding \
		-fno-threadsafe-statics \
		-Werror=return-type \
		-Wdouble-promotion \
		-Wno-register \
		-Wno-volatile \
		 $(EXTRACXXFLAGS) \

LINK_STDLIB ?= -nostdlib

LFLAGS = -Wl,--gc-sections \
		 -Wl,-Map,$(BUILDDIR)/$(BINARYNAME).map,--cref \
		 $(MCU)  \
		 -T $(LINKSCR) \
		 $(LINK_STDLIB) \
		 -nostartfiles \
		 -ffreestanding \
		 $(EXTRALDFLAGS) \

DEPFLAGS = -MMD -MP -MF $(OBJDIR)/$(basename $<).d

ARCH 	= arm-none-eabi
CC 		= $(ARCH)-gcc
CXX 	= $(ARCH)-g++
LD 		= $(ARCH)-g++
AS 		= $(ARCH)-as
OBJCPY 	= $(ARCH)-objcopy
OBJDMP 	= $(ARCH)-objdump
GDB 	= $(ARCH)-gdb
SZ 		= $(ARCH)-size

SZOPTS 	= -d

ELF 	= $(BUILDDIR)/$(BINARYNAME).elf
HEX 	= $(BUILDDIR)/$(BINARYNAME).hex
BIN 	= $(BUILDDIR)/$(BINARYNAME).bin

all: Makefile $(ELF) $(BIN) $(HEX)

install:
	cp $(UIMAGENAME) $(SDCARD_MOUNT_PATH)
	diskutil unmount $(SDCARD_MOUNT_PATH)

$(OBJDIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(info Building $< at $(OPTFLAG))
	@$(AS) $(AFLAGS) $< -o $@ 

$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d
	@mkdir -p $(dir $@)
	$(info Building $< at $(OPTFLAG))
	@$(CC) -c $(DEPFLAGS) $(OPTFLAG) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.c[cp]* $(OBJDIR)/%.d
	@mkdir -p $(dir $@)
	$(info Building $< at $(OPTFLAG))
	@$(CXX) -c $(DEPFLAGS) $(OPTFLAG) $(CXXFLAGS) $< -o $@

$(ELF): $(OBJECTS) $(LINKSCR)
	$(info Linking...)
	@$(LD) $(LFLAGS) -o $@ $(OBJECTS) 

$(BIN): $(ELF)
	$(OBJCPY) -O binary $< $@

$(HEX): $(ELF)
	@$(OBJCPY) --output-target=ihex $< $@
	@$(SZ) $(SZOPTS) $(ELF)

$(UIMAGENAME): $(BIN) $(UBOOTDIR)/tools/mkimage
	$(info Creating uimg file)
	@$(UBOOTDIR)/tools/mkimage -A arm -C none -T kernel -a $(LOADADDR) -e $(ENTRYPOINT) -d $< $@

$(UBOOTDIR)/tools/mkimage:
	$(info Building U-boot bootloader)
	@cd ../.. && scripts/build-u-boot.sh

%.d: ;

clean:
	rm -rf build

ifneq "$(MAKECMDGOALS)" "clean"
-include $(DEPS)
endif

.PRECIOUS: $(DEPS) $(OBJECTS) $(ELF)
.PHONY: all clean install

.PHONY: compile_commands
compile_commands:
	compiledb make
	compdb -p ./ list > compile_commands.tmp 2>/dev/null
	rm compile_commands.json
	mv compile_commands.tmp compile_commands.json
