/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/

//		BA - Monitor for AVR8 microcontroller in assembler (BAMO128)
//		############################################################
// developed on CharonII with atmega128 and 32K external SRAM
// works on arduinoMega with atmega1280 also

//      When I was your age, we had 8 bit CPUs and assembler!
//	And we liked it!
//	And we didn't complain! (adapted from www.ethernut.de)

; BA-Version 0.0	060102		BA-Berlin bh
; BA-Version 0.1	060309		FHW-Berlin/FB BA, Inf04
; BA-Version 0.2	060701		FHW-Berlin/FB BA, Inf04, Mathias Boehme
; BA-Version 0.21	061201		bh
; BA-Version 0.22	061227		bh
; BA-Version 0.4	091404		HWR-Berlin/FB BA, Inf07
; BA_Version 0.5	091711		bh -> arduinoMega, sysTime, dump sram error
; BA_Version 0.6	??????
; BA_Version 0.7	??????
; version 0.8 		112501 		bh -> arduino/skt500v1 upload protocol integrated and sw - reset of arduino board
;*****************************************************************************
// bamo128 in boot-flash-section from addr 0xF000 (words)
// c-programms are written to 0 and overwrite page0 (128 words) or 0x80
// asm programms starts at x80 (words)
// page 0 (128 words -> 256 bytes) reserved for monitor (IV-Tab)
// Timer2 with interrupt for step-command
// Timer 1 with interrupt for sysTime milliSec
// atmea128 on CharonII RAM:  0-0x1F (registers), 0x20-0xFF (io space), 0x100-0x10FF internal ram, 0x1100 -0x7FFF ext ram
// arduionoMega: only internal RAM
// monitor stack is located Ramend-0x100 (bytes) downwards
// monitor-ram  from (Ramend-0x100) to Ramend upwards

.NOLIST
#include	<avr/io.h>
.LIST
#include	"boarddefines.h"
#include	"defines.asm"

.global	mainLoop
.global BOOTSTART
.global JToutFlashText
.global JTspaceConOut
.global JTcearScreen
.global JTclearScreenFromPosition
.global JTlfcrConOut
.global JTsetBGColor
.global JTsetFGBlack

#ifndef TESTVERSION 		// real monitor
// real monitor must be programmed in bootsection of flash
// testversion you can load in application flash (with the resident "real monitor")
.org			0,0xff	
#include	"ivtab.asm"
#endif //!testversion
.org		BYTES(0x80),0xff	// application program 
		ret
// this works in bootsection for devieces with 4 kW boot section
.org			BYTES(MONSTART),0xff	// 0x80 or BOOTSECTION (0xF000 in words)
BOOTSTART:		cli			;  no interrupt when stack is changed
			rjmp	startMonitor
/* jump table with useful addresses for linking at application programs*/
			jmp	mainLoop			// BOOTSTART+2
			jmp	conIn				// BOOTSTART+4
			jmp	conOut				// BOOTSTART+6
			jmp	conStat				// BOOTSTART+8
			jmp	echo				// BOOTSTART+10
JToutFlashText:		jmp	outFlashText		// BOOTSTART+12
			jmp	conIn2Hex			// BOOTSTART+14
			jmp	conInByteSupWS	// BOOTSTART+16
			jmp	conInAdrSupWS			// BOOTSTART+18
			jmp	switchCase		// BOOTSTART+20
			jmp	testHex			// BOOTSTART+22
			jmp	hex2Ascii			// BOOTSTART+24
			jmp	loadInSRam		// BOOTSTART+26
			jmp	byteConOut		// BOOTSTART+28
			jmp	asciiConOut		// BOOTSTART+30
JTlfcrConOut:		jmp	lfcrConOut			// BOOTSTART+32
JTspaceConOut:		jmp	spaceConOut		// BOOTSTART+34
JTclearScreen:		jmp	clearScreen		// BOOTSTART+36
			jmp	clearLine			// BOOTSTART+38
			jmp	convert2LowerCase		// BOOTSTART+40
			jmp	setFGColor		// BOOTSTART+42
JTsetBGColor:		jmp	setBGColor		// BOOTSTART+44
			jmp	getEEPromByte	// BOOTSTART+46
			jmp	setEEPromByte	// BOOTSTART+48
			jmp	getFlashWord		// BOOTSTART+50
JTclearScreenFromPosition:	jmp	clearScreenFromPosition			// BOOTSTART+52
JTsetFGBlack:		jmp	setFGBlack				// BOOTSTART+54
			jmp	mySysClock				// BOOTSTART+56
			jmp	startTimer1				// BOOTSTART+58
			jmp	stopTimer1				// BOOTSTART+60
			jmp	saveCPU		//Time2Comp			// BOOTSTART+62	
						// jump for interrupt in step mode
			jmp	disAss		// BOOTSTART+64
#ifdef STK500PROTOCOLUPLOADFLASH		// arduino like
			jmp	0
#else
			jmp	upLoadFlashWithOffset // BOOTSTART+66 page: 0..512 arg in X
#endif
			jmp	getFlashByte	// BOOTSTART+68 only upper half of flash

; timer 1 interrupt service routine , sysclock millisec
mySysClock:	// timer1 interrupt service routine increment SYSTIME every millisec
		push ZL		
		push ZH
		push argVL
		in argVL,_SFR_IO_ADDR(SREG)
		push argVL
		ldi ZL, lo8(SYSTIME)
		ldi ZH,hi8(SYSTIME)
mySysClock1:	ld argVL,Z
		inc argVL
		st Z+,argVL
		brne mySysClock2
		cpi ZL,0x04	// 4 bytes unsigned int incremented?
		brne mySysClock1
mySysClock2:	pop argVL
		out _SFR_IO_ADDR(SREG),argVL
		pop argVL
		pop ZH
		pop ZL
		reti
