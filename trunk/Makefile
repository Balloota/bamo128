#	########## BAMO128 - a monitor for AVR8 microcontroller ###############
# Version 07. (01082010)
#
#* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
#* See the file "license.terms" for information on usage and redistribution of this file.
# 

# for development set TESTVERSION to 0x80 (1) instead of 0xf000 (0)
# step command doesnt work in test version
VERSION = NOTESTVERSION 
PROTOCOL = STK500PROTOCOLUPLOADFLASH
# arduino like, with reset before bootload
# if not defined use of old holznagel-protocol (not recommended)

# whats target platform !!

ifeq ($(findstring am,$(MAKECMDGOALS)),am)
	BOARD = ARDUINOMEGA
	MCU =	atmega1280
am:	
	@:
compile:	clean binary
burn:	 	clean binary upLoadAM
fuses:		writeFusesAM
all:		burn
endif

ifeq ($(findstring xplain,$(MAKECMDGOALS)),xplain)	# not realized yet
	BOARD = XPLAIN
	MCU =	atxmega128a1 
xplain:	
	@:
compile:	clean flash
burn:	 	clean flash upLoadAM
fuses:		writeFusesAM
all:		burn fuses
endif


ifeq ($(findstring ch,$(MAKECMDGOALS)),ch)
	BOARD = CHARON
	MCU =	atmega128
ch:
	@:
compile:	clean flash
burn: 		clean flash upLoadCH
fuses:		writeFusesCH
all:		burn fuses
endif

ifeq ($(findstring DU,$(MAKECMDGOALS)),du)
	BOARD = DUEMILANOVE
	MCU = atmega328
	#MCU =	atmega168
DU:
	@:
compile:	clean binary
upLoad: 	clean binary upLoadDU
fuses:		writeFusesCH
endif

#**************************************************************
OBJECTS	= 	bamo128.o  mainloop.o register.o \
		go.o   sram.o console.o    disass.o   flash.o  consolecontrol.o \
		transfer.o eeprom.o help.o stk500.o constants.o

MONITOR	= 	bamo128

#PROGRAMMER=mib510
PROGRAMMER=stk500

//TTY		= /dev/ttyS0
TTY		= /dev/ttyUSB0

.SUFFIXES:	.S .s .asm  .c .o   .eep .rom .cob .hex
# .cob are linked objects in binary format
# s-, S-Files for imported sources
# asm-Files for ba-sources

#TEXTSEGMENT	= 0x1E000
#TEXTSEGMENT	= 0x100

# binaries tools in avr32studio !!
BINDIR	= /opt/cross/as4e-ide/plugins/com.atmel.avr.toolchains.linux.x86*/os/linux/x86_64/bin/
CC	= $(BINDIR)avr-gcc
CPP	= $(BINDIR)avr-cpp
AS	=$(BINDIR) avr-as
LD	= $(BINDIR)avr-ld
UISP 	= uisp
RM	= rm -f
BIN	= $(BINDIR)avr-objcopy
ELFCOF  = objtool

#If all other steps compile ok then echo "Errors: none". -> everything went ok.

DONE    = @echo Errors: none


ARCHITECTURE	= avr5
#--- default assembler flags 
ASFLAGS   = -Wa,-gstabs -Wa,-ahlms=$(<:.asm=.lst) -Wa,-mmcu=$(MCU) -D$(PROTOCOL) -D$(BOARD)
#--- default linker flags
#LDFLAGS   = -Wl,-symbolic -Wl,-Map=$(PROJ).map,--cref,--defsym,__stack=0x1100 -nostartfiles -Ttext=0x1E000 -nodefaultlibs
#LDFLAGS =    -nostartfiles -nodefaultlibs   -Wl,-Ttext=$(TEXTSEGMENT) -Wl,-m$(ARCHITECTURE)  -mmcu=$(MCU)
LDFLAGS =     -Wl,-m$(ARCHITECTURE)  -mmcu=$(MCU) 
#-Wl,--section-start=.diss=0x4000
#-Wl,--gc-sections

#--- output format can be srec (Motorola), ihex (Intel HEX)
FLASHFORMAT 	= binary
IHEXFORMAT	= ihex

#--- assemble: instructions to create object file from assembler source
%o : %S
	$(CC) -x assembler-with-cpp -D$(BOARD)  -D$(VERSION) -gstabs -Wa,-ahlms=$(<:.asm=.lst) -mmcu=$(MCU)  -c $< -o $@

%o: %c
	$(CC)  -mmcu=$(MCU)  -D$(BOARD)  -D$(VERSION) -c $< -o $@

%o : %s
	$(CC) -x assembler-with-cpp -D$(BOARD)  -D$(PROTOCOL) -D$(VERSION) -gstabs -Wa,-ahlms=$(<:.asm=.lst) -mmcu=$(MCU) -I$(INCDIR) -c $< -o $@

%o : %asm
	$(CC) -x assembler-with-cpp -D$(BOARD) -D$(VERSION) -D$(PROTOCOL) -gstabs -Wa,-ahlms=$(<:.asm=.lst) -mmcu=$(MCU)   -c $< -o $@

#--- create flash file (binary) from elf output file overwrite elf file: result in .cob file
%elf: %bin
	$(BIN)    -O $(FLASHFORMAT)  $< 

%hex: %bin
	$(CC) $(LDFLAGS) -nostartfiles $(OBJECTS)  -o $<
	$(BIN)       -O $(IHEXFORMAT)  $< $@



#*************************** add your projects below **************************************
#--- this defines the aims of the make process
help:		
	@echo 'usage: #>make TARGET command'
	@echo 'TARGET: am (for ArduinoMega); ch for Charon'
	@echo 'command:'
	@echo '         clean'
	@echo '         compile'
	@echo '         burn (ch with stk500 and uisp; cm with avrISPmkII and avrdude)'
	@echo '         fuses (write controller fuses)'
	@echo '         clean '



binary:	$(OBJECTS)
	$(CC)  $(LDFLAGS)   -nostartfiles -nodefaultlibs   $(OBJECTS)  -o $(MONITOR).elf
	@echo last byte: `avr-objdump -d bamo128.elf | tail -n2| sed '$d'| cut -f1| sed 's/://'`
	$(DONE)

hex:		$(MONITOR).hex


# load monitor in atmega128 (CharonII)

upLoadCH:		
	$(BIN)     -O $(IHEXFORMAT)  $(MONITOR).elf  $(MONITOR).hex
	sudo $(UISP) -dprog=$(PROGRAMMER) -dserial=$(TTY) -dpart=$(MCU) -dspeed=115200 --erase --upload if=$(MONITOR).hex
	$(DONE)

writeFusesCH:
	sudo $(UISP) -dprog=$(PROGRAMMER) -dserial=$(TTY) -dpart=ATmega128 -dspeed=115200  \
			--wr_fuse_h=0x80 --wr_fuse_l=0x2F --wr_fuse_e=0xFF --wr_lock=0xFF
#|^ RESET -> jump to boot section!!

# fuer mote und bamo128 ->8.1.07
upLoadMote128:
	$(MAKE) clean
	$(CC)  $(LDFLAGS)   -nostartfiles -nodefaultlibs  $(OBJECTS)  -o $(MONITOR).elf
	$(BIN)     -O $(IHEXFORMAT)  $(MONITOR).elf  $(MONITOR).hex
	$(UISP) -dprog=mbi510 -dserial=$(TTY) -dpart=ATmega128 -dspeed=115200  \
			--wr_fuse_h=0xd8 --wr_fuse_l=0xFF --wr_fuse_e=0xFF --wr_lock=0xFF
	$(DONE)

upLoadAM:
	$(BIN)     -O binary  $(MONITOR).elf  $(MONITOR).bin
	sudo avrdude -p m1280 -c avrispmkII -D -Pusb  -V -e -Uflash:w:bamo128.bin:a
	$(DONE)

upLoadDU:
	$(BIN)     -O binary  $(MONITOR).elf  $(MONITOR).bin
	avrdude  -p m328P -c avrispmkII -Pusb  -e -Uflash:w:/home/bh/Desktop/repos/bamo128/bamo128.bin:a
	$(DONE)


#avrdude -p m1280 -c avrispmkII -e -P usb  -Uflash:w:bamo128.hex:i

writeFusesAM:
	sudo avrdude -p m1280 -c avrispmkII  -P usb  -Ulfuse:w:0xff:m
	sudo avrdude -p m1280 -c avrispmkII  -P usb  -Uhfuse:w:0xd8:m
	sudo avrdude -p m1280 -c avrispmkII  -P usb  -Uefuse:w:0xf5:m

readFusesCH:
	$(UISP) -dprog=$(PROGRAMMER) -dserial=$(TTY) -dpart=ATmega128 -dspeed=115200  --rd_fuses

writeResetCH:
	$(UISP) -dprog=$(PROGRAMMER) -dserial=$(TTY) -dpart=ATmega128 -dspeed=115200  --wr_fuse_h=0x80

writeFactoryCH:
	$(UISP) -dprog=$(PROGRAMMER) -dserial=$(TTY) -dpart=ATmega128 -dspeed=115200  \
			--wr_fuse_h=0x81 --wr_fuse_l=0x2F --wr_fuse_e=0xFF --wr_lock=0xFF
# |^fuer Charon-demo

clean:
	$(RM) *.rom *.eep  *.hex *.cob *.bin *.elf
	$(RM) *.o 
	$(RM) *.lst 
	$(RM) *.map
	$(RM)  $(MONITOR)


# avrdude -p m1280 -c avrispmkII -e -P usb -v -U flash:w:bamo128.cob
# doesnt work, because byte order wrong!!

# avrdude -p m1280 -c avrispmkII -e -P usb -v -Uflash:w:bamo128.hex:i

# avrdude -p m1280 -c avrispmkII  -P usb -v -Ulock:w:0xff:m 

#avrdude: safemode: lfuse reads as FF
#avrdude: safemode: hfuse reads as (DA) d8
#avrdude: safemode: efuse reads as F5
