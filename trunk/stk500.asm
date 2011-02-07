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
.global writeSpmBlock
.global writeSpmPage
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
			movw	r4,XL		// length in bytes
			ldi	YL,lo8(SPM_WRITEBUFFER)
			ldi	YH,hi8(SPM_WRITEBUFFER)
writeData0:		rcall	conIn
			st	Y+,argVL
			sbiw	XL,1
			brne	writeData0	// data in buf
			movw	XL,r4		// restore length in bytes
			rcall	conIn
			cpi	argVL,' '
			brne	byteResponse2	// ret
			ldi	YL,lo8(SPM_WRITEBUFFER)
			ldi	YH,hi8(SPM_WRITEBUFFER)			
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
writeFlash:		rcall	writeSpmBlock
			rjmp	nothingResponse3

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

; Y sram data buffer in bytes
; X length in bytes
; r16, Z flash address in bytes
writeSpmBlock:		in	r15,_SFR_IO_ADDR(SREG)
			cli		//todo
			ldi	r17,0		// page count
			sbiw	XL,0
			breq	retSPM		// nothing to burn
			adiw	XL,1		// even bytes
			lsr	XH		// %2 length in words
			ror	XL
writeSpmBlock0:		inc	r17		// count pages
			subi	XL,SPM_PAGESIZE/2	// compute pages in words (and burn pages!!)
			sbci	XH,0
			breq	writeSpmBlock1
			brcc	writeSpmBlock0
writeSpmBlock1:		ldi	r16,0
			andi	ZL,SPM_PAGESIZE_MASK	// all other make not sense
			add	ZL,ZL			// burn full pages !!
			adc	ZH,ZH
			adc	r16,r16			// r16,ZH,ZL holds flash byte address
writeSpmBlock2:		rcall	writeSpmPage
			dec	r17		// still pages
			brne	writeSpmBlock2
			out	_SFR_IO_ADDR(SREG),r15	// todo
			ret 
			
; Y sram data buffer in bytes
; r16, Z flash address in bytes (starts at page bounderies xxx00)
writeSpmPage:		out	_SFR_IO_ADDR(RAMPZ),r16
#ifdef ARDUINODUEMILANOVE
			ldi	argVL, (1<<PGERS) |  (1<<SELFPRGEN)	//  Page Erase
			rcall	Do_spm
			ldi	argVL, (1<<RWWSRE) |  (1<<SELFPRGEN)	// re-enable the RWW section
#else
			ldi	argVL, (1<<PGERS) | (1<<SPMEN)	//  Page Erase
			rcall	Do_spm
			ldi	argVL, (1<<RWWSRE) | (1<<SPMEN)	// re-enable the RWW section		
#endif
			rcall	Do_spm			// transfer data from RAM to Flash page buffer
			ldi	r18, SPM_PAGESIZE/2	// init loop variable in words
			movw	r6,ZL			// save Z
			mov	r4,r16			// save RAMPZ
writeSpmPage0:		ld	r0, Y+
			ld	r1, Y+
#ifdef ARDUINODUEMILANOVE
			ldi	argVL, (1<<SELFPRGEN)
#else
			ldi	argVL, (1<<SPMEN)
#endif
			rcall	Do_spm
			adiw	ZL, 2
			brcc	writeSpmPage1
			inc	r16			// RAMPZ
writeSpmPage1:		dec	r18
			brne	writeSpmPage0
			movw	r8,ZL
			mov	r5,r16
			movw	ZL,r6
			mov	r16,r4
			rcall	uploadwrite
			movw	ZL,r8
			mov	r16,r5
retSPM:			ret				// r16, Z -> added page size in bytes
							// Y -> added page size in byte


// avrdude -pm1280 -D -Uflash:w:Blink.bin:a -c stk500v1 -P/dev/ttyUSB0 -V -b57600
// das geht mit arduino bootloader (weil ohne int??)
// aber nicht mit 328p macht er kein reset????
//./avrdude -pm1280 -D -Uflash:w:Blink.bin:a -carduino -P/dev/ttyUSB0 -V -b57600
// das geht mit bamo128/ wegen DTR oder so bit