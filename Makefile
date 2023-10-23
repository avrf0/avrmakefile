######## AVR Makefile ########
# Project name
PRJ = tn817

# MCU configuration
MCU = attiny817
CLK = 20000000

# Programmer
PRG = xplainedmini_updi

## Input directories
SRC = src
INC = src

## Output directories
BUILD = build
OBJDIR = build/obj

## Sources lists
CFILES := $(foreach dir, $(SRC), $(wildcard $(dir)/*.c))
CPPFILES := $(foreach dir, $(SRC), $(wildcard $(dir)/*.cpp))
ASMFILES := $(foreach dir, $(SRC), $(wildcard $(dir)/*.S))
INCLUDE := $(foreach dir, $(INC), -I$(dir))
OBJ = $(foreach dir,$(CFILES:.c=.o) $(CPPFILES:.cpp=.o) $(ASMFILES:.S=.o),$(OBJDIR)/$(dir))

## Programs configuration
CC = /usr/bin/avr-gcc
CXX = /usr/bin/avr-g++
OBJCOPY = /usr/bin/avr-objcopy
OBJDUMP = /usr/bin/avr-objdump
SIZE = /usr/bin/avr-size
AVRDUDE = /usr/bin/avrdude

## Flags
CFLAGS = -Wall -Og -ggdb -DF_CPU=$(CLK) -mmcu=$(MCU) $(INCLUDE)
CPPFLAGS =
ASFLAGS = $(CFLAGS) -x assembler-with-cpp
LDFLAGS = -Wl,-Map,$(BUILD)/$(PRJ).map,--cref -mrelax -Wl,--gc-sections -Wl,-u,vfprintf -lprintf_flt -lm -mmcu=$(MCU)

## Targets

all: 	$(BUILD)/$(PRJ).hex

clean:
	rm -rf $(BUILD)

flash:  all
	$(AVRDUDE) -c$(PRG) -p$(MCU) -U flash:w:$(BUILD)/$(PRJ).hex:i -U eeprom:w:$(BUILD)/$(PRJ).eep:i

avrdudetest:
	$(AVRDUDE) -c$(PRG) -p$(MCU) -vvv

install: flash	# Added to provide compatibility with KDevelop



## Rules to build the files

# Object files
$(OBJDIR)/%.o: %.c
	@echo "$< -> $@"
	@test -d $(OBJDIR) || mkdir -pm 775 $(OBJDIR)
	@test -d $(@D) || mkdir -pm 775 $(@D)
	@-$(RM) $@
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/%.o: %.cpp
	@echo "$< -> $@"
	@test -d $(OBJDIR) || mkdir -pm 775 $(OBJDIR)
	@test -d $(@D) || mkdir -pm 775 $(@D)
	@-$(RM) $@
	$(CXX) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJDIR)/%.o: %.S
	@echo "$< -> $@"
	@test -d $(OBJDIR) || mkdir -pm 775 $(OBJDIR)
	@test -d $(@D) || mkdir -pm 775 $(@D)
	@-$(RM) $@
	$(CC) $(ASFLAGS) -c $< -o $@

# Elf file
$(BUILD)/$(PRJ).elf: $(OBJ)
	$(CXX) $(LDFLAGS) -o $(BUILD)/$(PRJ).elf $(OBJ)
	$(SIZE) --format=avr --mcu=$(MCU) $(BUILD)/$(PRJ).elf

# Hex file
$(BUILD)/$(PRJ).hex: $(BUILD)/$(PRJ).elf
	rm -f $(BUILD)/$(PRJ).hex
	$(OBJCOPY) -O ihex -R .eeprom $(BUILD)/$(PRJ).elf $(BUILD)/$(PRJ).hex
	$(OBJCOPY) -j .eeprom -O ihex $(BUILD)/$(PRJ).elf $(BUILD)/$(PRJ).eep
