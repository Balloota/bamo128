/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/

#include	<avr/io.h>
#include "boarddefines.h"
#include "defines.asm"
.global	dumpExit
.global	sRamDump
.global	getSRamByte
.global	setSRamByte
.global	loadInSRam
.global	upLoadSRam
//autor: 			Andre Höhn, Anna Schobert ;###   SRAM   ### 
//date of creation: 		06.03.2006
//date of last modification:	12.03.2009

//affected regs. flags:		all
// Neuentwurf bh 1.10.06

; YL,YH 			Arbeitsadresse
; SPos -> r18  0-> position auf erste hex eines Bytes, FFFF-> zweites hex eines Bytes
//#define	loop	r17
#define		SPos 	r18
#define		which	r19		// eeprom or sram ueber eine Funktion!!
sRamDump:	rcall	conInADRSupWSTestCR		; Adresse zum Anzeigen Abfragen < RAMEND ???
		ldi	argVL, BLACK
		rcall	setBGColor			; Hintergrund auf schwarz setzen
sRamLoop:	push		YL
		push		YH
		rcall		sRamShow						; SRAM ausschreiben
		pop		YH
		pop		YL
		ldi		argVL,0x12						; endPos
						rcall		setCursorYUp
						rcall		saveCursor
						rcall		lfcrConOut
						rcall		lfcrConOut
						push		YL
						andi		YL,0x0f				// lower tetrade
						mov		argVL,YL
						add		argVL,argVL		// \*2
						add		argVL,YL			//\*3
						subi		argVL,-5
						rcall		setCursorXRight
						pop		YL
						clr			SPos
sRamLoop1:			rcall		conControlIn
						cpi			argVL,0x21			;Space
						;breq		sRamDumpControl	
						;brlo		sRamDumpControl	
						brlt		sRamDumpControl				;jump to controlroutine if controlkey
						//brtc		dumpExit						// non hex 
						rcall		conOut
						rcall		ascii2Hex			
						mov		argVH,argVL					// new value
						rcall		getSRamByte					// old value
						com		SPos
						breq		sRamLowerHex
sRamHigherHex:		andi		argVL,0x0f
						swap		argVH
						or			argVL,argVH
						rcall		setSRamByte
						rjmp		sRamLoop1
sRamLowerHex:		andi		argVL,0xf0
						rcall		spaceConOut
						or			argVL,argVH
						rcall		setSRamByte
sRamLowerHex1:			adiw		YL,1
						ldi		argVL,0x0f
						and		argVL,YL
						brne		sRamLoop1
						rcall		lfcrConOut
						ldi			argVL,5
						rcall		setCursorXRight
						rjmp		sRamLoop1		;line,page up down !!

sRamDumpControl:	rcall		switchCase
						.byte		LFCR			;ENTER
						.word		pm(dumpExit)
						.byte		CURSORLEFT
						.word		pm(sRamDumpControlCL)
						.byte		CURSORRIGHT
						.word		pm(sRamDumpControlCR)
						.byte		CURSORUP		;added by Anna Schobert
						.word		pm(sRamDumpControlCU)  
						.byte		CURSORDOWN		;added by Anna Schobert
						.word		pm(sRamDumpControlCD) 
						.byte		SPACE			;added by Anna Schobert
						.word		pm(sRamDumpControlS)
						.byte		TAB			;addded by Anna Schobert
						.word		pm(sRamDumpControlT)
						.byte		0			
						.word		pm(sRamLoop1)
.align 1
sRamDumpControlCL:				com	SPos
						brne	sRamDumpControlCL1		;higher hex
						rcall	cursorBack						; lower hex
						rjmp	sRamLoop1

sRamDumpControlCL1:				
						com SPos
							mov	argVL,YL
							andi	argVL,0x0f
							;breq	sRamLoop1
							breq	sRamLineUp
							sbiw	YL,1

							com SPos
							rcall	cursorBack
							rcall	cursorBack
							
						rjmp sRamLoop1 
sRamDumpControlT:			ldi	argVL,0x00
					cp	SPos, argVL
					breq	sRamDumpControlS		;jmp if cursor on lower hex
					rcall	cursorFor
					rcall	cursorFor
						adiw		YL,1		; compare sRamLowerHex1
						ldi		argVL,0x0f
						and		argVL,YL
						brne		sRamDumpControlT1
						rcall		lfcrConOut
						ldi			argVL,5
						rcall		setCursorXRight
						rjmp		sRamDumpControlT1	
sRamDumpControlT1:				rcall	cursorFor
						rjmp sRamLoop1
sRamLineUp:			sbiw		YL,0x01					;added by Anna Schobert
						com		SPos
						ldi		argVL,0x01		;Line up
						rcall		setCursorYUp
						ldi		argVL,0x2E		;end of line
						rcall		setCursorXRight
						rjmp		sRamLoop1						
sRamDumpControlCR:				com	SPos
						breq	sRamDumpControlCR1		;lower hex
						rcall	cursorFor						; higher hex
						rjmp	sRamLoop1

sRamDumpControlCR1:				rcall	cursorFor
						rcall	cursorFor
						rjmp sRamLowerHex1	
						;rjmp	sRamLoop1

sRamDumpControlCD:				adiw		YL,0x10
						ldi		argVL,0x01
						rcall		setCursorYDown
						rjmp		sRamLoop1	
	
sRamDumpControlCU:				sbiw	YL,0x10
						ldi		argVL,0x01
						rcall		setCursorYUp
						rjmp		sRamLoop1	

sRamDumpControlS:			ldi	argVL,0x00
					cp	SPos, argVL
					brne	sRamDumpControlS1		;jmp if cursor on low hex
					
					rcall	cursorFor
					rcall	cursorFor
					rcall	cursorFor
					rjmp sRamLowerHex1

sRamDumpControlS1:			com 	SPos
					rjmp	sRamDumpControlCR1
		
dumpExit:				rjmp		restoreCursor
						//rjmp		cursorUp
						
sRamShow:			rcall		setFGGreen			; Farbe setzen
						rcall		outFlashText
.string	"\r\n     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F ab 0x20 stehen io-register??\r\n"	;Header ausgeben
.align 1
						andi		YL,0xf0
						ldi			loop,0x10			; anz zeilen
sRamMatrixLoop:		rcall		setFGGreen
						mov		argVL,YL
						mov		argVH,YH
						rcall		adrConOut			; erste Spalte (Adresse) ausgeben
						rcall		setFGWhite
						rcall		spaceConOut			; Leerzeichen ausgeben
						rcall		sRamLine				; SRAM-Zeile ausgeben - HEX
						rcall		lfcrConOut				; springe zu Anfang nächste Zeile
						dec		loop
						brne		sRamMatrixLoop
sRamMatrixEnd:		ret

sRamLine:				ldi			r18,0x10				; spaltenzahl
sRamLine0:			rcall		getSRamByte
						rcall		byteConOut			; Ausgabe des Wertes
						rcall		spaceConOut			; Ausgabe Leerzeichen
						adiw		YL,1
						dec		r18						; loop inkrementieren
						brne		sRamLine0			; wenn loop >= 17 springe zu sRamLineEnde
						ldi			r18,0x10				; 0 in loop laden
						sbiw		YL,0x10
sRamLine1:			rcall		getSRamByte
						rcall		asciiConOut			; Ausgabe des Wertes
						adiw		YL,1
						dec		r18						; loop inkrementieren
						brne		sRamLine1			; wenn loop >= 17 springe zu sRamAsciiEnde
						ret

getSRamByte:		or			YH,YH
			breq		getSRamByte1	; special registers in sRam from MON !!!
getSRamEnd:		ld			argVL,Y
			ret
getSRamByte1:		cpi			YL,0x20
			brlo		getSRamByte3		// bh 10.11.09!!!
			mov		argVL,YL
			rcall		switchCase
			.byte		SREG
			.word		pm(getSRamByte3)
			.byte		SPL
			.word		pm(getSRamByte3)
			.byte		SPH
			.word		pm(getSRamByte3)
			.byte		RAMPZ
			.word		pm(getSRamByte3)						
			.byte		0
			.word		pm(getSRamEnd)
.align 1
						
getSRamByte3:		subi		YL,lo8(-MON)
			sbci		YH,hi8(-MON)
			ld		argVL,Y				; special registers in sRam from MON !!!
			subi		YL,lo8(MON)
			sbci		YH,hi8(MON)
			ret

setSRamByte:		push		YL
			push		YH
			push		argVL
			or		YH,YH
			breq		setSRamByte1	// ist it a cpu reg?
setSRamEnd:		pop		argVL		// no
			st		Y,argVL
			pop		YH
			pop		YL
			ret
setSRamByte1:		cpi		YL,0x20		// is it a reg
			brlo		setSRamByte3
			mov		argVL,YL
			rcall		switchCase	// or SREG and so
			.byte		SREG
			.word		pm(setSRamByte3)
			.byte		SPL
			.word		pm(setSRamByte3)
			.byte		SPH
			.word		pm(setSRamByte3)
			.byte		RAMPZ
			.word		pm(setSRamByte3)						
			.byte		0
			.word		pm(setSRamEnd)	//bh no!! it is ram or io-reg!
.align 1
						
setSRamByte3:		subi		YL,lo8(-REG)	// write it in monram
			sbci		YH,hi8(-REG)
			rjmp		setSRamEnd   //bh

#ifndef STK500PROTOCOLUPLOADFLASH
uploadendS2:		ldi	argVL,0x5
			rcall	serOut
						clr	R24
						clr R25
						rjmp	upLoadEnd
					
uploaderrorS:				ldi		argVL,0x5
							rcall	serOut				; turn off echo
							rjmp	uploaderror

upLoadSRam:				rcall	outFlashText
.string	"\r\nfrom File in SRAM!!! -> sta: "
.align 1
							rcall		conInAdrSupWS		// test for valid addresses!!
							movw		R24,YL					// ram -adr
							rcall	outFlashText				// Z modified
.string	"\r\ngib klein 'w' ein:"
.align 1
							nop
loadInSRam:				push	YL			; for C -> save all registers
							push	YH
							push	loop
							push	XL
							push	XH
							push	ZL
							push	ZH		
							movw	YL,r24		// sram-> sta
							movw	XL,r24		// save sta
							rcall	conIn		; dummy //w?
							cpi		argVL,'w'
							brne	uploadendS2
							ldi		argVL,0x4
							rcall	serOut				; turn off echo
							rcall	serIn				//s							
							cpi		retVL,'s'			; start upload cmd
							brne	uploaderrorS
nextpageS:				rcall	serIn
							cpi		retVL,'e'			; after last page
							breq	uploadendS
							cpi		retVL,'p'			; a pages comes
							brne	uploaderrorS
							rcall	serIn
							rcall	serIn				; address
							ldi		argVL,'w'
							rcall	serOut				; readyNow
							ldi		loop ,0x0			; bytes in SRam
PageLoopS:				rcall	serIn				; low byte instr
							st		Y+,argVL
							dec	loop
							brne	PageLoopS
							ldi		argVL,'w'
							rcall	serOut				; readyNow
							rjmp	nextpageS
uploadendS:				ldi		argVL,0x5
							rcall	serOut				; turn on echo
							ldi		YL,0
							ldi		YH,0
upLoadEnd1:				rcall	conIn
							cpi		argVL,' '
							breq	upLoadEnd1
upLoadEnd2:				rcall ascii2Hex
							add	YL,YL
							adc	YH,YH
							add	YL,YL
							adc	YH,YH
							add	YL,YL
							adc	YH,YH
							add	YL,YL
							adc	YH,YH
							or		YL,argVL
							rcall	conIn
							cpi		argVL,LF
							brne	upLoadEnd2
							movw R24,YL
uploadendS0:							rcall	 adrConOut
upLoadEnd:				pop	ZH
							pop	ZL
							pop	XH
							pop	XL
							pop	loop
							pop	YH
							pop	YL
							ret
	
#endif