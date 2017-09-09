TARGET=screen.elf
C_SOURCES=
ASM_SOURCES=start.S util.S screen.S keypad.S main.S
ASM_OUTPUT=$(TARGET).s
OBJ_FILES=$(ASM_SOURCES:.S=.o) $(C_SOURCES:.c=.o)
GCC_ROOT=/opt/gcc-mips-7.1.0
LD=$(GCC_ROOT)/bin/mips-elf-ld
CC=$(GCC_ROOT)/bin/mips-elf-gcc
AS=$(GCC_ROOT)/bin/mips-elf-as
OBJDUMP=$(GCC_ROOT)/bin/mips-elf-objdump
CFLAGS=-G 0 -Os -Wall -ffreestanding -fno-stack-protector \
	   -nostdinc -nostdlib -fdelayed-branch -fno-builtin
ELF_TO_MIF=../tools/elf2mif
IMEM_FILE=../sim/inst_mem.mif
DMEM_FILE=../sim/data_mem.mif
IMEM_WORD_COUNT=4096
DMEM_WORD_COUNT=1024

.PHONY: clean run
.SUFFIXES:

all: mem_files $(ASM_OUTPUT)

mem_files: $(TARGET)
	$(ELF_TO_MIF) $^ $(IMEM_FILE) $(DMEM_FILE) $(IMEM_WORD_COUNT) $(DMEM_WORD_COUNT)
	> mem_files

$(TARGET): $(OBJ_FILES)
	$(LD) -G 0 -T link_script.ld -o $@ $^

%.o: %.S
	$(CC) $(CFLAGS) -c -mips1 -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -mips1 -o $@ $<

$(ASM_OUTPUT): $(TARGET)
	$(OBJDUMP) -D $< > $@

run: mem_files
	cd ../sim/ && ./VMIPS32SOC

clean:
	rm -f $(TARGET)
	rm -f *.o
	rm -f *.mif
	rm -f *.bin mem_files
	rm -f $(ASM_OUTPUT)
