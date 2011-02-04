/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
#include	<avr/io.h>
#include "boarddefines.h"
#include "defines.asm"
/*************************************************************************************************************/
//autor: 			Max Dubiel, Mathias Boehme 								;###   EEPROM   ### 
//date of creation: 		28.06.2006
//date of last modification:	28.09.2006
//inputs:
//outputs:
//affected regs. flags:		argVLWL, argVH, X (posx, posy), Z
//used subroutines:		abfangen, byteConOut, spaceConOut, asciiConOut, clearScreen, setFGColor, outFlashText, lfcrConOut
//changelog			28.09.2006 - Cursor-Funktionen auskommentiert - wird von abfangen uebernommen
.global eePromDump
.global	getEEPromByte
.global	setEEPromByte

// Neuentwurf bh 1.10.06

;YL,YH 			r28,r29 actual eeProm cell
;SL, SH 			r22, r23 ram

#define		SL		r22
#define		SH		r23
#define		SPos 	r18

//.section text1

eePromDump:			rcall			conInADRSupWSTestCR
						mov		SL,YL
						andi		SL, 0b11110000		; auf einen xxx0 - Wert geglaettet
						mov		SH,YH
						ldi			argVL, BLACK
						rcall		setBGColor			; Hintergrund auf schwarz setzen
eePromLoop:			push		YL
						push		YH
						mov		YL,SL
						mov		YH,SH
						rcall		eePromShow				; SRAM ausschreiben
						pop		YH
						pop		YL
						ldi			SPos,0
eePromLoop1:			rcall		conControlIn
						cpi			argVL,0x20
						brlo		eePromDumpControl
						rcall		convert2LowerCase
						rcall		testHex					
						brtc		eePromLoop1				; was sonst?
						rcall		conOut
						rcall		ascii2Hex
						mov		argVH,argVL
						rcall		getEEPromByte
						andi		SPos,1
						brne		eePromLowerHex				
						andi		argVL,0x0f
						swap		argVH
						rjmp		eeProm0
eePromLowerHex:		andi		argVL,0xf0
						rcall 		spaceConOut
eeProm0:				or			argVL,argVH
						rcall		setEEPromByte
						inc			SPos
						andi		SPos,1
						brne		eeProm1
						adiw		YL,1
eeProm1:				mov		argVL,YL				; cursorsteuerung vorwärts !!!!!
						cpi			SPos,0
						brne		eePromLoop1
						andi		argVL,0x0f
						brne		eePromLoop1
						rcall		lfcrConOut
						ldi			argVL,5
						rcall		setCursorXRight
						rjmp		eePromLoop1		;line,page up down !!


eePromDumpControl:	rcall		switchCase
						.byte		LFCR
						.word		pm(dumpExit)
						.byte		0
						.word		pm(eePromLoop1)
.align 1



eePromShowCell:	rcall		getEEPromByte
						rcall		byteConOut	; Ausgabe des Wertes
						rjmp		spaceConOut			; Ausgabe Leerzeichen

eePromShowLine:	push		loop				; loop-Register retten
						ldi			loop,0x10			; 0 in loop laden
eePromLineLoop:		rcall		eePromShowCell		; Subroutine SHOWRAMCELL aufrufen
						adiw		YL,1
						dec		loop				; loop inkrementieren
						brne		eePromLineLoop			; wenn loop >= 17 springe zu eePromLineEnde
eePromLineEnde:		pop		loop				; loop wiederherstellen
						ret

eePromShowAscii:		rcall		getEEPromByte
						rjmp		asciiConOut			; Ausgabe des Wertes
eePromShowAsciiLine:	push		loop				; loop-Register retten
						ldi			loop,0x10			; 0 in loop laden
eePromAsciiLoop:		rcall		eePromShowAscii			; Subroutine SHOWRAMCELL aufrufen
						adiw		YL,1
						dec		loop				; loop inkrementieren
						brne		eePromAsciiLoop			; wenn loop >= 17 springe zu eePromAsciiEnde
eePromAsciiEnde:		pop		loop				; loop wiederherstellen
						ret

eePromShow:			rcall		clearScreen			; Bildschirm löschen
						rcall		home
						ldi			argVL,GREEN			; Farbe grün wählen
						rcall		setFGColor			; Farbe setzen
						rcall		outFlashText
.string	"     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\r\n"	//;Header ausgeben
.align 1
						ldi			loop,0x10			; 0 in loop laden
eePromMatrixLoop:		LDI			argVL,GREEN
						rcall		setFGColor
						mov		argVL,YL
						mov		argVH,YH
						rcall		adrConOut			; erste Spalte (Adresse) ausgeben
						LDI			argVL,WHITE
						rcall		setFGColor
						rcall		spaceConOut			; Leerzeichen ausgeben
						push		YL
						push		YH
						rcall		eePromShowLine		; SRAM-Zeile ausgeben - HEX
						pop		YH
						pop		YL
						LDI			argVL,CYAN			; Farbe auf grau setzen
						rcall		setFGColor
						rcall		eePromShowAsciiLine		; SRAM-Zeile ausgeben - ASCII
						LDI			argVL,WHITE			; Farbe auf weiß setzen
						rcall		setFGColor
						rcall		lfcrConOut				; springe zu Anfang nächste Zeile
						dec		loop
						brne		eePromMatrixLoop
eePromMatrixEnd:		pop		argVH
						pop		argVL
						pop		YH
						pop		YL
						push		YL
						push		YH
						push		argVL
						push		argVH
						mov		argVL,YL		;	set Cursor
						mov		argVH,YH
						sub		argVL,SL
						sbc		argVH,SH
						mov		argVH,argVL		; 16 x 16
						push		argVH
						andi		argVL,0x0f
						mov		argVH,argVL
						add		argVL,argVL
						add		argVL,argVH
						subi		argVL,-5
						pop		argVH
						swap		argVH
						andi		argVH,0x0f
						subi		argVH, -1
						rcall		setCursorXY
						ret

getEEPromByte:		sbic	_SFR_IO_ADDR(EECR),BAMOEEWE
			rjmp	getEEPromByte			; make sure EEPROM is ready
			out	_SFR_IO_ADDR(EEARH),YH		; Set up address (r18:r17) in address register
			out	_SFR_IO_ADDR(EEARL),YL		; Start eeprom read by writing EERE
			sbi	_SFR_IO_ADDR(EECR), EERE
			in	retVL, _SFR_IO_ADDR(EEDR)	; Read data from data register
			ret
		
setEEPromByte:		sbic	_SFR_IO_ADDR(EECR), BAMOEEWE
			rjmp	setEEPromByte		; make sure EEPROM is ready
			out		_SFR_IO_ADDR(EEARH), YH
			out		_SFR_IO_ADDR(EEARL), YL
			out		_SFR_IO_ADDR(EEDR),argVL
			push	argVL
			in		argVL, _SFR_IO_ADDR(SREG)
			cli					; no ints between setting EEMWE and MYEEWE
			sbi		_SFR_IO_ADDR(EECR), BAMOEEMWE
			sbi		_SFR_IO_ADDR(EECR), BAMOEEWE
			out		_SFR_IO_ADDR(SREG), argVL
			pop	argVL
			ret
