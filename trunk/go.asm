/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
#include	<avr/io.h>
#include "boarddefines.h"
#include "defines.asm"
.global	go
.global	saveCPU
.global	step
.global	execute
.global	break
.global startTimer1
.global stopTimer1
;################  Monitor-BasisFunktionen Anfang ##############
// autors:  					Mathias Boehme										;###   GO   ### 
// date of creation: 		06.03.2006
// date of last modification	08.06.2006
// inputs:			
// outputs:			
// affected regs. flags:	
// used subroutines:	conInAdr,conIn2Hex,showRegister
// changelog			08.06.2006 - Registerausgabe am Ende formatiert
// comment				beinhaltet die Registerausgabe am Ende 
// neuentwurf bh

startTimer1:	push 	argVL
		STARTMILLISECTIMER
		pop	argVL
		sei
		ret

stopTimer1:	push 	argVL
		push	argVH
		in	argVH,_SFR_IO_ADDR(SREG)
		STOPMILLISECTIMER
		out	_SFR_IO_ADDR(SREG),argVH
		pop	argVH
		pop	argVL
		ret

go:		clr	R26
		sts	ISSTEPORBREAK,R26	; no break, no step
		rcall	conInPCSupWSTestCR
//		rcall 	lfcrConOut
restoreCPU:	lds	R27,USERSP	; never return, jump to user program
		out	_SFR_IO_ADDR(SPL),R27
		lds	R27,USERSP+1
		out	_SFR_IO_ADDR(SPH),R27	; user sp laden
		ldi	ZL,27
		clr	ZH
		ldi	YL,lo8(REG+27)
		ldi	YH,hi8(REG+27)
go4:		ld	R27,-Y
		st	-Z,R27
		or	ZL,ZL
		brne	go4				; R0-R26 laden
#ifndef DUEMILANOVE
		lds	R27,USERRAMPZ
		out	_SFR_IO_ADDR(RAMPZ),R27
#endif
		ldi	R28,lo8(pm(saveCPU))
		ldi	R29,hi8(pm(saveCPU))
		push	R28
		push	R29
		lds	R27,ISSTEPORBREAK
		or	R27,R27
		breq	go5				; go
		pop	R29				;step or execute break
		pop	R28				; goEnd from Stack
		lds	R30,USERPC
		sts	LASTPC,R30
		push	R30
		lds	R31,USERPC+1
		sts	LASTPC+1,R31
		push	R31
		lds	R28,REG+28
		lds	R29,REG+29
		lds	R30,REG+30	
		lds	R31,REG+31		;R27  -R31 laden
		rcall	stopTimer1		; no yet interrupt of timer 1!!!
		STARTSTEPTIMER			// is 8 bit timer 2															; zaehlt in TCNT2 /Timer/CouNTer) hoch
		sei								; Set Enable Interupt
		lds		R27,REG+27
		ret

go5:		lds		R30,USERPC
							push	R30
							lds		R31,USERPC+1
							push	R31
							lds		R27,USERSREG
		out	_SFR_IO_ADDR(SREG),R27		;RAMPZ und SREG laden			
							lds		R27,REG+27
							lds		R28,REG+28
							lds		R29,REG+29
							lds		R30,REG+30	
		lds		R31,REG+31		;R27  -R31 laden
		ret	; oberster Wert auf Stack == START-Adresse --> Beginn von Programm
							; ###   Start Programm   ###

// return from user program
saveCPU:						cli
							sts		REG+27,R27
							sts		REG+28,R28
							sts		REG+29,R29
							sts		REG+30,R30
		sts		REG+31,R31			; R27 -R31 retten
#ifndef DUEMILANOVE
							in		R27,_SFR_IO_ADDR(RAMPZ)
#endif
							sts		USERRAMPZ,R27
							in		R27,_SFR_IO_ADDR(SREG)
		sts		USERSREG,R27			; RAMPZ  und SREG retten
							ldi		ZL,27
							clr		ZH
							ldi		YL,lo8(REG+27)
							ldi		YH,hi8(REG+27)
goEnd1:					ld		R27,-Z
							st		-Y,R27
							or		ZL,ZL
		brne	goEnd1					; R0 . R26 retten
							lds		R27,ISSTEPORBREAK
							or		R27,R27
							breq	go22
							pop	R31
							pop	R30						; next user instruction addr
							; from goEnd (rcall saveCPU) or next inst from rcall ISR (rcall SaveCPU)		-> user stack is empty
go22:							in		R28,_SFR_IO_ADDR(SPL)
							sts		USERSP,R28
							in		R29,_SFR_IO_ADDR(SPH)
							sts		USERSP+1,R29
							ldi		R28,lo8(STACKMON-1)		; Oberes Byte
							out		_SFR_IO_ADDR(SPL),R28						; an Stapelzeiger monitor stack
							ldi		R29, hi8(STACKMON-1) 		; Unteres Byte
							out		_SFR_IO_ADDR(SPH),R29							; stackwechsel	
							DISABLESTEPINTERRUPTS
							lds		R27,ISSTEPORBREAK
							or		R27,R27
							breq	goEnd22		; is go
							;step or execute break
							sts		USERPC,R30
							sts		USERPC+1,R31
							STOPSTEPTIMER
							lds		R27,ISSTEPORBREAK
							cpi		R27,1
							breq	goEnd23	; step
							rcall		compareBreakPoints
							brts	goEnd22	; break				; address is in break or is mainLoop
							rjmp	restoreCPU
goEnd2:							rjmp	showRegister
goEnd22:	ldi	argVL,0
		sts	SUPPRESSHEADLINE,argVL
		rjmp	goEnd2
goEnd23:	ldi	argVL,1
		sts	SUPPRESSHEADLINE,argVL
		rjmp	goEnd2

// autor:  			Henning Schmidt										;###   STEP   ### 
//				Mathias Boehme
// date of creation: 		06.03.2006
// date of last modification	10.06.2006
// inputs:			-
// outputs:			
// affected regs. flags:	I,T, argVL, argVLWL, argVH, mpr,R25, X,Y, R31
// used subroutines:		conInAdr, conIn2Hex, setFontcolor, srRegisteranzeigen, spaceConOut, outFlashText
// changelog			
//				10.06.2006 - Markennamen geaendert, Struktur ueberarbeitet, mit "sts BAMOTIFR,(1<<OCF2)" interrupt ordentlich beendet
//						--> Step funktioniert
//					   - Am Ende PC aus Programm in USERPC & Promt+"s" fuer direkten naechsten Step
//					   - Ausfuehren mehrerer Einzelschritte
//					   - Modularisierung - fuer Zugriff auf stepOneStep durch X (execute)
;Step fuehrt nur einen einzigen Befehl aus und kehrt dann in den Monitor zurueck, wahlweise koennen auch 2-f Befehle ausgefuehrt werden.
;BAMo128 #>s Sta Anz
;BAMo128 #>s Sta 
;BAMo128 #>s
;neuentwurf bh
step:						rcall	conInPCSupWSTestCR
							clr		R16
							brts	step1
step5:						or		R16,argVL
							rcall	conIn2Hex
							brts	step1
							add	r16,r16
							add	r16,r16
							add	r16,r16
							add	r16,r16
							rjmp	step5		
								
step1:						sts		NUMSTEPS,R16	
							ldi		r27,1
							sts		ISSTEPORBREAK,r27
							lds	argVL,SUPPRESSHEADLINE
							cpi	argVL,LFCR
							breq	step11
							rcall showHeadLine
step11:							rjmp	restoreCPU

// autor:  			Mathias Boehme										;###   EXECUTE  ### 
// date of creation: 		11.06.2006
// date of last modification	11.06.2006
// inputs:			
// outputs:			
// affected regs. flags:	
// used subroutines:
// changelog

execute:					ser		R26							;0xff
							sts		ISSTEPORBREAK,R26	; break
							rcall		conInPCSupWSTestCR
execute1:					rjmp 	restoreCPU



// autor:  			Mathias Boehme										;###   BREAKPOINTS   ### 
// date of creation: 		10.06.2006
// date of last modification	10.06.2006
// inputs:			
// outputs:			
// affected regs. flags:	R18, argVL, argVLWL, argVH, retVL, retVH, Y, X, T-Flag, C-Flag
// used subroutines:		conIn2Hex, conInAdr, adrConOut, lfcrConOut, spaceConOut, outFlashText, setFGColor
// changelog
// neuwentwurf bh
break:			rcall		outFlashText
.string		"\b\bBreaks at: "
.align 1
				ldi		YL,lo8(BREAKADDR)
				ldi		YH,hi8(BREAKADDR)
				ldi		XL,MAXNUMBRKPOINTS
break0:		ld		argVL,Y+
				ld		argVH,Y+
				rcall		adrConOut
				rcall 	spaceConOut
				dec	XL
				brne	break0
				ldi		YL,lo8(BREAKADDR)
				ldi		YH,hi8(BREAKADDR)
				ldi		argVL,40
				rcall 	setCursorXLeft
break1:		dec	XL				// Position in adr
				andi	XL,0x03
break3:		rcall		conControlIn
				cpi		argVL,0x20
				brlt		breakControl
				brtc	break3		// non hex				
				rcall		conOut
				rcall		ascii2Hex
				mov	argVH,argVL
				mov	argVL,XL
				rcall		switchCase
.byte			1
.word			pm(break01)
.byte			2
.word			pm(break10)
.byte			3
.word			pm(break11)
.byte			0
.word			pm(break00)
.align 1

break00:		rcall		spaceConOut
				ld		argVL,Y
				andi	argVL,0xf0
				or		argVH,argVL
				st		Y+,argVH		; zeigt auf high byte
				ld		argVL,Y+		; dummy zeigt auf low from next
				rjmp	break1
break01:		ld		argVL,Y
				andi	argVL,0x0f
				swap	argVH
				or		argVH,argVL
				st		Y,argVH		;
				rjmp	break1
break10:		ldd		argVL,Y+1
				andi	argVL,0xf0
break100:		or		argVH,argVL
				std		Y+1,argVH		;
				rjmp	break1
break11:		ldd		argVL,Y+1
				andi	argVL,0x0f
				swap	argVH
				rjmp	break100

				
breakControl:	rcall		switchCase
.byte		LFCR
.word		pm(mainLoop)
.byte		0
.word		pm(break1)
.align 1



compareBreakPoints:	lds	XL,USERPC
						lds	XH,USERPC+1
						ldi	YL,lo8(BREAKADDR)
						ldi	YH,hi8(BREAKADDR)
						ldi	argVH,MAXNUMBRKPOINTS
						set
						ldi	argVL,lo8(pm(mainLoop))
						cp	argVL,XL
						ldi	argVL,hi8(pm(mainLoop))
						cpc	argVL,XH
						breq	compareBrkEnd
compareBrk0:		ld	argVL,Y+
						cp	argVL,XL
						ld	argVL,Y+
						cpc	argVL,XH
						breq	compareBrkEnd
						dec	argVH
						brne	compareBrk0
						clt
compareBrkEnd:		ret					

