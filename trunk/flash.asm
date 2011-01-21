/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
//  bh 1.10.06
#include	<avr/io.h>
#include "defines.asm"
#include "boarddefines.h"

.global	flashDump
.global	getFlashWord
.global	upLoadFlash
.global	switchCase
.global	outFlashText	
.global Do_spm
.global	uploaderror
.global upLoadFlashWithOffset
.global	getFlashByte
.global prepareUpLoadFlash
.global prepareUpLoad

// author:  			Tilo Kussatz 										;###   FLASH   ### 
// date of creation: 		06.03.2006
// date of last modification:	10.03.2006
// inputs:			-
// outputs:			-
// affected regs. flags:	-
// used subroutines:		conInAdr, showFlashMatrix, abfangenY
// changelog:			28.09.2006 - Mathias Boehme - changed address request and navigation to common procedure
//							      no more Cursor up / down navigation
// Passes the supplied argVLument word to showFlashMatrix.
// After the initial matrix of flash memory words has been displayed, cursor control is enabled to
// allow page navigation. Supported keys are PAGE UP, PAGE DOWN
// RETURN returns to the main prompt.

	; gibt den FLASH als 8x16 Matrix aus.
	; mit den CursorTasten kann zwischen den Bytes navigiert werden
	; es können alle Bytes bearbeitet werden!!
	; BildAuf wechselt zur Adresse 0x0100 weiter vorne und gibt die Matrix neu aus
	; BildAb wechselt zur Adresse 0x0100 weiter hinten und gibt die Matrix neu aus

;YL,YH 			r28,r29 aktuelle flashzelle
;SL, SH 			r22, r23 flash sta-links oben
; SPos -> r18  0-> position auf erste hex eines Bytes, 1-> zweites hex eines Bytes

#define		SL		r22
#define		SH		r23
#define		SPos 	r18

flashDump:			rcall		conInADRSupWSTestCR
						mov		SL,YL
						andi		SL, 0b11111000		; auf einen xxx8 - Wert geglaettet
						mov		SH,YH	
				rjmp	skippy
				jmp	BOOTSTART	; ist for devices witk 2K word bott section, make it better
skippy:				ldi		argVL, BLACK		
				rcall		setBGColor			; Hintergrund auf schwarz setzen
flashLoop:					push		YL
						push		YH
						mov		YL,SL
						mov		YH,SH
						rcall		flashShow				; SRAM ausschreiben
						pop		YH
						pop		YL
						ldi			SPos,0
flashLoop1:			rcall		conControlIn		// to do!!

flashDumpControl:		rcall		switchCase
						.byte		LFCR
						.word		pm(dumpExit)
						.byte		0
						.word		pm(dumpExit)
.align 1

flashShowCell:		rcall		getFlashWord
						rcall		adrConOut	; Ausgabe des Wertes
						rjmp		spaceConOut			; Ausgabe Leerzeichen

flashShowLine:		push		loop				; loop-Register retten
						ldi			loop,0x8			; 0 in loop laden
flashLineLoop:		rcall			flashShowCell		; Subroutine SHOWRAMCELL aufrufen
						adiw		YL,1
						dec		loop				; loop inkrementieren
						brne		flashLineLoop			; wenn loop >= 17 springe zu flashLineEnde
flashLineEnde:		pop		loop				; loop wiederherstellen
						ret

flashShowAscii:		rcall		getFlashWord
						rcall		asciiConOut
//						push	argVL
						mov	argVL,argVH
//						rcall		asciiConOut
//						pop	argVL
						rjmp		asciiConOut			; Ausgabe des Wertes
flashShowAsciiLine:	push		loop				; loop-Register retten
						ldi			loop,0x8			; 0 in loop laden
flashAsciiLoop:		rcall		flashShowAscii			; Subroutine SHOWRAMCELL aufrufen
						adiw		YL,1
						dec		loop				; loop inkrementieren
						brne		flashAsciiLoop			; wenn loop >= 17 springe zu flashAsciiEnde
flashAsciiEnde:		pop		loop				; loop wiederherstellen
						ret

flashShow:			rcall		clearScreen			; Bildschirm löschen
						rcall		home
						ldi			argVL,GREEN			; Farbe grün wählen
						rcall		setFGColor			; Farbe setzen
						rcall		outFlashText
.string	"       00   01   02   03   04   05   06   07\r\n"	;Header ausgeben
.align 1
						ldi			loop,0x10			; 0 in loop laden
flashMatrixLoop:		LDI			argVL,GREEN
						rcall		setFGColor
						mov		argVL,YL
						mov		argVH,YH
						rcall		adrConOut			; erste Spalte (Adresse) ausgeben
						LDI			argVL,WHITE
						rcall		setFGColor
						rcall		spaceConOut			; Leerzeichen ausgeben
						push		YL
						push		YH
						rcall		flashShowLine		; SRAM-Zeile ausgeben - HEX
						pop		YH
						pop		YL
						LDI			argVL,CYAN			; Farbe auf grau setzen
						rcall		setFGColor
						rcall		flashShowAsciiLine		; SRAM-Zeile ausgeben - ASCII
						LDI			argVL,WHITE			; Farbe auf weiß setzen
						rcall		setFGColor
						rcall		lfcrConOut				; springe zu Anfang nächste Zeile
						dec		loop
			brne		flashMatrixLoop
flashMatrixEnd:		pop		argVH
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


// author:  			Tilo Kussatz
// date of creation: 		07.03.2006
// date of last modification:	10.03.2006
// inputs:			Y
// outputs:			retVL: Byte 1, retVH: Byte 2
// affected regs. flags:	-
// used subroutines:		-
// changelog:
// Returns the flash memory *word* argVH,argVLreferenced by the Y
// Z-Reg modified
getFlashWord:	push		ZL
		push		ZH
		movw		ZL,YL
		lsl		ZL				; shift Z to the left (into RAMPZ). (-> * 2)
		rol		ZH
		clr		argVL
		brcc		getFW0
		inc		argVL
getFW0:		out		_SFR_IO_ADDR(RAMPZ), argVL
		elpm		retVL, Z+			; get 1st byte (and increment)
		elpm		retVH, Z			; get 2nd byte
		pop		ZH
		pop		ZL
		ret

getFlashByte:	push	ZH				; C conform only upper half of flash
		push	ZL
		push	r17
		in 	r17,_SFR_IO_ADDR(RAMPZ)
		ldi	ZL,1
		out	_SFR_IO_ADDR(RAMPZ),ZL
		movw	ZL,argVL
		elpm	retVL,Z
		out	_SFR_IO_ADDR(RAMPZ),r17
		pop	r17
		pop	ZL
		pop	ZH
		ret

#ifndef STK500PROTOCOLUPLOADFLASH
// special bamo128 upload protocol

upLoadFlashWithOffset:	clt
			rcall	outFlashText
.string	"\b\bwrite flash words from 0000 to ff80(128 words pages): "
.align 1
			rcall	conInAdrSupWSTestCR
			add	YL,YL
			adc	YH,YH
			ldi	YL,0
			rol	YL
			movw	XL,YL
			rcall	outFlashText
.string	"\r\ntype w"
.align 1
			rcall	conIn
			rjmp	upLoadFlashWithOffset1
#endif
uploaderror:		ldi		argVL,0x5
			rcall	serOut				; turn on echo	
			rcall	outFlashText
.string	"\r\nflash write error???\r\n"
.align 1	
			rjmp	mainLoop

#ifdef STK500PROTOCOLUPLOADFLASH		// arduino like
prepareUpLoadFlash:	// after reset
			// rcall	stopTimer1
prepareUpLoad:		// with bamo-w-command
prepareBootLoading0:	ldi	YL,lo8(pm(prepareBootLoading0))
			ldi	YH,hi8(pm(prepareBootLoading0))
			push	YL
			push	YH

prepareBootLoading2:	rcall	waitForKeyStroke
			sbrs	argVL,0
			rjmp	mainLoop
prepareBootLoading1:rcall	conIn
		rcall	switchCase
		.byte 	'd'	
		.word	pm(writeData)
		.byte 	'U'	
		.word	pm(getAdr)
		.byte	'0'
		.word	pm(nothingResponse)
		.byte 	'1'	
		.word	pm(requestProgrammerID)
		.byte 	'@'	
		.word	pm(boardCommand)
		.byte 	'A'	
		.word	pm(boardRequest)
		.byte 	'B'	
		.word	pm(deviceParameter)
		.byte 	'E'	
		.word	pm(parProgrammer)
		.byte 	'P'	
		.word	pm(nothingResponse)
		.byte 	'R'	
		.word	pm(nothingResponse)
		.byte 	'Q'		; quhuhhh!!!	
		.word	pm(reEnter)
		.byte 	'V'	
		.word	pm(universalSPI)
		.byte 	't'	
		.word	pm(readData)
		.byte 	'u'	
		.word	pm(getSignature)
		.byte 	'v'	
		.word	pm(byteResponse0)
		.byte	0					; default
		.word	pm(prepareBootLoading0)
.align 1

#else // not recommended
upLoadFlash:		ldi	XL,0	// RAMPZ 0 or 1
			ldi	XH,0	// 256 pages with 256 words

upLoadFlashWithOffset1:  	rcall	stopTimer1
		ldi	argVL,0x4
		rcall	serOut				; turn off echo
		rcall	serIn
		cpi	retVL,'s'			; start upload cmd
		brne	uploaderror
		clr	ZL				; only full pages
nextpage:	rcall	serIn
		cpi	retVL,'e'			; after last page
		breq	uploadend
		cpi	retVL,'p'			; a pages comes
		brne	uploaderror
		rcall	serIn				; 0 or 1
		mov	argVH,argVL			; lower or upper bank
		rcall	serIn				; word address
		add	argVL,XH
		adc	argVH,XL
		andi	argVH,1
		out	_SFR_IO_ADDR(RAMPZ),argVH
		mov	ZH,argVL
//		sts	RAMPZ,retVL			; lower or upper bank?
//		rcall	serIn	
//		mov	ZH,argVL			; page


		ldi 	argVL, (1<<PGERS) | (1<<SPMEN)	; page erase
		rcall	Do_spm
		ldi	argVL, (1<<RWWSRE) | (1<<SPMEN)	; re-enable the RWW section
		rcall	Do_spm
		ldi	argVL,'w'
		rcall	serOut				; readyNow
		ldi	loop ,0x80			; words in page r17
PageLoop:	rcall	serIn				; low byte instr
		mov	r0,retVL
		rcall	serIn				; high byte instr
		mov	r1,retVL	
		ldi	argVL, (1<<SPMEN)		; transfer data bytes from RAM to Flash page buffer
		rcall	Do_spm
		inc	ZL				; next word
		inc	ZL
//		ldi	argVL,'w'
//		rcall	serOut				; readyNow
		dec	loop
		brne	PageLoop
		clr	ZL
		rcall	uploadwrite			; write page in flash
		ldi	argVL,'w'
		rcall	serOut				; readyNow
		rjmp	nextpage
uploadend:	rcall	conInAdrSupWS
		ldi	argVL,0x5
		rcall	serOut			;; turn on echo
		movw	argVL,YL
		rjmp	adrConOut

// fuer Version 0.22
#endif
							
							
							

/*****************************************************************/


Do_spm:		in	argVH, _SFR_IO_ADDR(SREG)
		push	argVH
		cli
Do_spm1:
#ifdef ARDUINOMEGA
		in 	 argVH,_SFR_IO_ADDR(SPMCSR)	; check for previous SPM complete
#endif
#ifdef CHARON
		lds 	 argVH,SPMCSR	; check for previous SPM complete
#endif
		sbrc 	argVH, SPMEN
		rjmp 	Do_spm1
#ifdef ARDUINOMEGA
waitEE:		sbic	_SFR_IO_ADDR(EECR),EEPE
		rjmp	waitEE
#endif
#ifdef ARDUINOMEGA
		out 	_SFR_IO_ADDR(SPMCSR), argVL	; check for previous SPM complete
#endif
#ifdef CHARON
		sts 	 SPMCSR, argVL	; check for previous SPM complete
#endif
		spm
		pop	argVH
		out	_SFR_IO_ADDR(SREG),argVH
		ret

// ZH,ZL modified
switchCase:		pop	ZH
			pop	ZL
			push	argVL
			push	argVH
			in	argVH,_SFR_IO_ADDR(RAMPZ)
			push	argVH
			clr		argVH		//0
			lsl		ZL
			rol		ZH
			brcc	switchCase0
			inc 	argVH
switchCase0:		out	_SFR_IO_ADDR(RAMPZ),argVH
switchCase2:		elpm	argVH,Z+
			or		argVH,argVH
			breq	switchCaseEnd	// ende der fahnenstange
			cp		argVH,argVL
			breq	switchCaseEnd		// gefunden
			elpm	argVH,Z+
			elpm	argVH,Z+
			rjmp	switchCase2
switchCaseEnd:		elpm	argVL,Z+
			elpm	ZH,Z
			mov	ZL,argVL
			pop	argVH
			out	_SFR_IO_ADDR(RAMPZ),argVH
			pop	argVH
			pop	argVL
			ijmp
// ZH,ZL modified
outFlashText:		pop 	ZH				; write text from text segment
							pop 	ZL				; get flash-textaddress->Initialize Z-pointer				
							push	argVL
							in		argVL,_SFR_IO_ADDR(SREG)
							push	argVL
							push	argVH
							in		argVL,_SFR_IO_ADDR(RAMPZ)
							push	argVL
							lsl		ZL
							rol 	ZH	
							clr  	argVH
							brcc	outFlashText0
							inc		argVH
outFlashText0:				out		_SFR_IO_ADDR(RAMPZ),argVH 
outFlashText2:				elpm	argVL, Z+ 			; Load byte from Program Memory address in Z und RAMPZ
							or		argVL,argVL
							breq	outFlashText1			; ende
							rcall	conOut
							rjmp	outFlashText2
outFlashText1:				ror		argVH
							ror		ZH
							ror		ZL
							pop	argVH
							out	_SFR_IO_ADDR(RAMPZ),argVH
							pop	argVH
							pop	argVL
							out	_SFR_IO_ADDR(SREG),argVL
							pop	argVL
							ijmp					; next instruction after text
							
