/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
#include <avr/io.h>
#include "defines.asm"
#include "boarddefines.h"

.global	mainLoop
.global	startMonitor

;############################# cold start of monitor / reset start ##################################
startMonitor:		ENABLEEXTERNALRAM
startClearBreaks:	clr	zeroReg				// for C-compiler
			ldi	argVL,2*MAXNUMBRKPOINTS+6
			ldi	YL, lo8(BREAKADDR)
			ldi	YH, hi8(BREAKADDR)
startClearBreaksLoop:	st	Y+,zeroReg
			dec	argVL
			brne	startClearBreaksLoop
			ldi	argVL,lo8(STACKUSER-1)
			sts	USERSP,argVL
			ldi	argVH,hi8(STACKUSER-1)			; sicherheitshalber user stack setzen!!
			sts	USERSP+1,argVH
			ENABLEMONITORUART
			sts	ISSTEPORBREAK,zeroReg
			sts	USERSREG,zeroReg
			out	_SFR_IO_ADDR(SREG),zeroReg
			ldi	argVL,lo8(STACKMON-1)		; Oberes Byte
			out	_SFR_IO_ADDR(SPL),argVL		; an Stapelzeiger monitor stack
			ldi	argVH, hi8(STACKMON-1) 		; Unteres Byte
			out	_SFR_IO_ADDR(SPH),argVH
#if ARDUINODUEMILANOVE || ARDUINOMEGA 
			rcall	waitForKeyStroke
			sbrc	argVL,0
			jmp prepareUpLoadFlash			// if key presses immediately after reset jump to upload flash
#endif
mainLoop7:		rcall	JToutFlashText					;Ausgabe des StartStrings
.string	"\r_______BAMo128 Version:"
.align 1
			rcall	JToutFlashText	
.string			VERSION
.align 1
			rcall	JToutFlashText
.string	" flash from: "
.align 1
 			ldi     argVL,hi8(pm(BOOTSTART))
			rcall	byteConOut
 			ldi     argVL,lo8(pm(BOOTSTART))
			rcall	byteConOut	
.align 1
			ldi	argVL,'-'
			rcall	conOut
 			ldi     argVL,hi8(pm(bamoEnd))
			rcall	byteConOut
 			ldi     argVL,lo8(pm(bamoEnd))
			rcall	byteConOut
			rcall	JToutFlashText
.string	" _____\r\nfrom students of the BA Berlin written for the "
.align 1				
#ifdef CHARON
			rcall	JToutFlashText
.string	"Charon 2\r\n"
.align 1	
#endif
#ifdef ARDUINOMEGA
			rcall	JToutFlashText
.string	"ArduinoMega\r\n"
.align 1	
#endif
#ifdef ARDUINODUEMILANOVE
			rcall	JToutFlashText
.string	"ArduinoDuemilanove\r\n"
.align 1	
#endif
;###############################################################################################
	;restart after command execution or program end (rjmp mainLoop)
mainLoop:	cli
		ldi	argVL,lo8(STACKMON-1)		; Oberes Byte
		out	_SFR_IO_ADDR(SPL),argVL
		ldi	argVH, hi8(STACKMON-1) 		; Unteres Byte
		out	_SFR_IO_ADDR(SPH),argVH
		ldi	ZH,hi8(pm(mainLoop))
		ldi	ZL,lo8(pm(mainLoop))
		rcall	startTimer1			// sei also milliSec Timer with interrupt
// uncomment this above, if you understand avr interrupt handling
// you can use the millisec timer 1 and step timer 0 with arduino applications also -> see arduinoAndBamo128Interrupts.txt
		push	ZL
		push	ZH	; return mainLoop on stack
		rcall	JTsetFGBlack
		ldi	argVL,WHITE
		rcall	JTsetBGColor
		rcall	JTlfcrConOut
		rcall	JTclearScreenFromPosition
		rcall	JToutFlashText
.string	"BAMo128 #>"		; the prompt
.align 1
mainLoop6:	rcall	conIn
		set
		cpi	argVL,LFCR		
		sts	SUPPRESSHEADLINE,argVL	; lfcr -> suppress headline r-command
		breq	mainLoop5
		clt
		cpi	argVL,'w'	// upload flash at address 0
		brne	mainLoop9
		ldi	argVL,'F'
mainLoop9:	cpi	argVL,'W'	// upload flash at address
		brne	mainLoop8
		ldi	argVL,'F'
mainLoop8:	mov	argVH,argVL
		cpi	argVL,'F'	// upload flash
		breq	mainLoop4
		cpi	argVL,'S'	// upload sram
		breq	mainLoop4
		cpi	argVL,'E'	// upload eeprom
		breq	mainLoop4
		sts	LASTCOMMAND,argVL
mainLoop5:	lds	argVL,LASTCOMMAND
		rcall	conOut
		rcall	JTspaceConOut
mainLoop4:	rcall	switchCase
		.byte	'm'
		.word	pm(sRamDump)
#ifdef	STK500PROTOCOLUPLOADFLASH
		.byte	'F'		// upload flash at address (0)
		.word	pm(prepareUpLoad)
		.byte	'E'
		.word	pm(prepareUpLoad)
		.byte	'S'
		.word	pm(prepareUpLoad)
#else
		.byte	'w'
		.word	pm(upLoadFlash)	// upload with bamo128 - command
		.byte	'j'
		.word	pm(upLoadFlashWithOffset)
		.byte	'W'
		.word	pm(upLoadSRam)
#endif
		.byte	'r'
		.word	pm(showRegister)
		.byte	'R'
		.word	pm(ShowRegister)	
		.byte	'g'
		.word	pm(go)
		.byte	's'
		.word	pm(step)
		.byte	'x'
		.word	pm(execute)
		.byte	'b'
		.word	pm(break)
		.byte	'a'
		.word	pm(showAuthors)
		.byte	'e'
		.word	pm(eePromDump)
		.byte	'h'
		.word	pm(showHelp)
		.byte	'f'
		.word	pm(flashDump)			
		.byte	'c'
		.word	pm(copy)
		.byte	'u
		.word	pm(dissass)				
; end of table
		.byte	0					; default
		.word	pm(noInstr)
.align 1
noInstr:	rcall	outFlashText
.string	"\r\nPress h for help..."
.align 1			
		ret
