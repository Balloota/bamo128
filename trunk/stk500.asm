/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
/*
 * stk500 protocoll for upload binary data at flash or eeprom
 * bamo128 can be used as arduino bootloader
 * apps start not automatically if no terminal interaction (e.g. terminal-sw minikermit.googlecode.com)
 * (feel free to change this behavior)
 * arduinoMega with atmega1280
 */ 
#include <avr/io.h>
#include "boarddefines.h"
#include "defines.asm"

/* SW_MAJOR and MINOR needs to be updated from time to time to avoid warning message from AVR Studio */
#define HW_VER	 0x02
#define SW_MAJOR 0x01
#define SW_MINOR 0x12

/* define various device id's */
/* manufacturer byte is always the same */
#define SIG1	0x1E	// Yep, Atmel is the only manufacturer of AVR micros.  Single source :(
// built in #define __AVR_ATmega1280__

#ifdef __AVR_ATmega1280__
#define SIG2		0x97
#define SIG3		0x03
#define PAGE_SIZE	0x80	// 128 words
#define	PAGE_SIZE_MASK	0x80
#define WRITEBUFFER	0x200	// bytes to be written stored in user sdram
// mask for last page bits
#elif __AVR_ATmega128__
#define SIG2		0x97
#define SIG3		0x02
#define PAGE_SIZE	0x80	// 128 words
#define	PAGE_SIZE_MASK	0x80
#define WRITEBUFFER	0x200	// bytes to be written stored in user sdram
// mask for last page bits
#elif defined __AVR_ATmega328P__
#define SIG2		0x95
#define SIG3		0x0F
#define PAGE_SIZE	0x40	// 64 words
#define	PAGE_SIZE_MASK	0xC0	// mask for last page bits
#define WRITEBUFFER	0x200	// bytes to be written stored in user sdram
#endif

#define	PAGE_SIZE_BYTE	(2*(PAGE_SIZE))		// page size <= 128 !!!

#ifdef STK500PROTOCOLUPLOADFLASH
.global nothingResponse
.global requestProgrammerID
.global boardCommand
.global boardRequest
.global deviceParameter
.global parProgrammer
.global getAdr
.global reEnter
.global universalSPI
.global writeData
.global readData
.global getSignature
.global byteResponse0
.global testing
.global testBurn
.global upLoadSim
//.section text1
boardCommand:		rcall	conIn			// '@'
			cpi	argVL,0x85+1
			brlo	nothingResponse
			rcall	conIn

nothingResponse:	rcall	conIn			// '0'
			//cpi	argVL,' '		// if (getch()==' ') {putch(0x14);putch(0x10);}
			//brne	byteResponse2		// ret
nothingResponse3:	ldi	argVL,0x14
nothingResponse4:	rcall	conOut
nothingResponse5:	ldi	argVL,0x10
			rjmp	conOut

boardRequest:		rcall	conIn			// 'A'
			rcall	switchCase		// Z modified???
			.byte	0x80
			.word	pm(hardWareVersion)
			.byte	0x81
			.word	pm(swMajor)
			.byte	0x82
			.word	pm(swMinor)
			.byte	0x98			//???
			.word	pm(byte03)
			.byte	0x00			// the default jump
			.word	pm(byteResponse0)
.align 1

byte03:			ldi	argVL,0x03
			rjmp	byteResponse
swMajor:		ldi	argVL,SW_MAJOR
			rjmp	byteResponse
swMinor:		ldi	argVL,SW_MINOR
			rjmp	byteResponse
hardWareVersion:	ldi	argVL,HW_VER
			rjmp	byteResponse

deviceParameter:	ldi	argVH,20		// 'B'
deviceParameter0:	rcall	conIn
			dec	argVH
			brne	deviceParameter0
			rjmp	nothingResponse

parProgrammer:		ldi	argVH,5			// 'E'
			rjmp	deviceParameter0
			
reEnter:		rcall	nothingResponse		// 'Q'
			jmp	mainLoop

getAdr:			rcall	conIn			// 'U' 
			mov	r20,argVL		// preserve r20 r21
			rcall	conIn			// address, little endian. EEPROM.SRAM in bytes, FLASH in words 
			mov	r21,argVL
			rjmp	nothingResponse		// if (getch()==' ') {putch(0x14);putch(0x10);
			
universalSPI:		ldi	argVH,4			// 'V' ???
universalSPI0:		rcall	conIn
			dec	argVH
			brne	universalSPI0
//			rjmp	byteResponse0

byteResponse0:		ldi	argVL,0			// 'v'
byteResponse:		push	argVL		// if (getch()==' '){putch(0x14);putch(val);putch(0x10);}
			rcall	conIn
			cpi	argVL,' '
			//brne	byteResponse1
			ldi	argVL,0x14
			rcall	conOut
			pop	argVL
			rjmp	nothingResponse4
byteResponse1:		pop	argVL
byteResponse2:		ret

writeData:		rcall	conIn		// 'd'            length is big endian and is in bytes
			mov	XH,argVL
			rcall	conIn
			mov	XL,argVL	// preserve X !!
			movw	ZL,r20
			rcall	conIn
			mov	argVH,argVL	// F,E or S
			push	XL
			push	XH		// length in bytes
			ldi	YL,lo8(WRITEBUFFER)
			ldi	YH,hi8(WRITEBUFFER)
writeData0:		rcall	conIn
			st	Y+,argVL
			sbiw	XL,1
			brne	writeData0	// data in buf
			pop	XH		// restore length in bytes
			pop	XL
			rcall	conIn
			cpi	argVL,' '
			brne	byteResponse2	// ret
			ldi	YL,lo8(WRITEBUFFER)
			ldi	YH,hi8(WRITEBUFFER)			
			cpi	argVH,'F'
			breq	writeFlash	// write flash
			cpi	argVH,'S'	// I dont know. Is it stk500 compatible. But it is useful!!!
			breq	writeSram
writeEeprom:		movw	r4,YL	; swap Z Y
			movw	YL,ZL
			movw	ZL,r4
writeEeprom1:		ld	argVL,Z+	// write eeprom
			rcall	setEEPromByte
			adiw	YL,1
			sbiw	XL,1
			brne	writeEeprom1
			rjmp	nothingResponse3
writeSram:		ld	argVL,Y+	// write sram
			st	Z+,argVL
			sbiw	XL,1
			brne	writeSram
			rjmp	nothingResponse3			
//Y-> write buffer, Z -> flash address  X -> length
writeFlash:		ldi	r16,0
			andi	ZL,PAGE_SIZE_MASK	// all other make not sense
			add	ZL,ZL			// burn full pages !!
			adc	ZH,ZH
			adc	r16,r16			// r16,ZH,ZL holds flash byte address
			ldi	r17,0
			sbiw	XL,0
			breq	writeData5	// nothing to burn
			adiw	XL,1		// even bytes
			lsr	XH		// %2 length in words
			ror	XL
writeData3:		inc	r17		// count pages
			subi	XL,PAGE_SIZE	// compute pages (and burn pages!!)
			sbci	XH,0
			breq	writeData4	// all other make not sense
			brcc	writeData3
writeData4:			// now write pages			
			out	_SFR_IO_ADDR(RAMPZ),r16
#ifdef ARDUINODUEMILANOVE
			ldi	argVL, (1<<PGERS) |  (1<<SELFPRGEN)	//  Page Erase
			rcall	Do_spm
			ldi	argVL, (1<<RWWSRE) |  (1<<SELFPRGEN)	// re-enable the RWW section
#else
			ldi	argVL, (1<<PGERS) | (1<<SPMEN)	//  Page Erase
			rcall	Do_spm
			ldi	argVL, (1<<RWWSRE) | (1<<SPMEN)	// re-enable the RWW section		
#endif
			rcall	Do_spm					// transfer data from RAM to Flash page buffer
			ldi	r18, PAGE_SIZE				// init loop variable
			movw	r6,ZL
writeData6:		ld	r0, Y+
			ld	r1, Y+
#ifdef ARDUINODUEMILANOVE
			ldi	argVL, (1<<SELFPRGEN)
#else
			ldi	argVL, (1<<SPMEN)
#endif
			rcall	Do_spm
			adiw	ZL, 2
			sbci	r16,0					// RAMPZ
			dec	r18
			brne	writeData6
			movw	r8,ZL
			movw	ZL,r6
			rcall	uploadwrite
			movw	ZL,r8
			dec	r17		// still pages
			brne	writeData4
writeData5:		rjmp	nothingResponse3

readData:		rcall	conIn		// 't'     length is big endian and is in bytes ???
			mov	XH,argVL
			rcall	conIn
			mov	XL,argVL	// preserve X !!
			rcall	conIn
			mov	argVH,argVL	// E or not E
			rcall	conIn
			cpi	argVL,' '
			brne	requestProgrammerID0	// ret
			ldi	argVL,0x14
			ldi	r16,0
			rcall	conOut
			movw	ZL,r20
			add	ZL,ZL
			adc	ZH,ZH
			adc	r16,r16		// RAMPZ
			movw	YL,ZL		// address
			cpi	argVH,'E'
			brne	readData0
readData1:		rcall	getEEPromByte
			rcall	conOut
			adiw	YL,1
			sbiw	XL,1
			brne	readData1
			rjmp	nothingResponse5
readData0:		out	_SFR_IO_ADDR(RAMPZ),r16		//flash
			elpm	argVL,Z
			rcall	conOut
			adiw	ZL,1
			brne	readData2
			inc	r16
readData2:		sbiw	XL,1
			brne	readData0
			rjmp	nothingResponse5	

requestProgrammerID:	rcall	conIn			// '1'
			cpi	argVL,' '
			brne	requestProgrammerID0
			rcall	outFlashText
.string	"\024AVR ISP\020"
.align 1
requestProgrammerID0:	ret

getSignature:		rcall	conIn			// 'u'
			//cpi	argVL,' '
			//brne	requestProgrammerID0	// ret
			ldi	argVL,0x14
			rcall	conOut
			ldi	argVL,SIG1
			rcall	conOut
			ldi	argVL,SIG2
			rcall	conOut
			ldi	argVL,SIG3
			rcall	conOut
			rjmp	nothingResponse5
#endif
// avrdude -pm1280 -D -Uflash:w:Blink.bin:a -c stk500v1 -P/dev/ttyUSB0 -V -b57600
// das geht mit arduino bootloader (weil ohne int??)
// aber nicht mit 328p macht er kein reset????
//./avrdude -pm1280 -D -Uflash:w:Blink.bin:a -carduino -P/dev/ttyUSB0 -V -b57600
// das geht mit bamo128/ wegen DTR oder so bit