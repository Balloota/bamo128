/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
#include	<avr/io.h>
#include "defines.asm"
// author:  			Raik Gülow, Robert Janisch		;###   REGISTER   ### 
// date of creation: 		10.03.2006
// date of last modification	12.03.2009
// inputs:	
// outputs:	
// affected regs. flags:	
// used subroutines: 		setCursorXLeft, setCursorXRight, byteConOut, setFGColor, conIn, outFlashText, 
//				spaceConOut, conOut, adrout, setCursorYUp,asciiConOut, hex2Ascii
// changelog 			ausgabe Textzeile
//	     			ausgabe CPU Zustand HEX
//	     			Coursorsteuerung zu einzelnen werten 
//				05.06.2006 - Markennamen geaendert
//				08.06.2006 - Registerausgabe formatiert
//				11.06.2006 - PC und SP richtig mit adrConOut ausgegeben
//				12.03.2009 - modify PC, SP and Flags

#include "boarddefines.h"

; YL,YH 			working address
.global 	showRegister
.global		ShowRegister
.global		showHeadLine

showHeadLine:	rcall	setFGBlue			; Farbe setzen
		rcall	outFlashText
.string	"\r\nPC   Code Mnemonic     ITHSVNZCE SP   X-26 Y-28 Z-30 R:16 17 18 19 20 21 22 23 24 25\r\n"
.align 1	
		ret

showRegister:	
		lds	argVL,	SUPPRESSHEADLINE
		cpi	argVL,0
		breq	showReg99		; go
		cpi	argVL,1			;step
		breq	showReg9
		cpi	argVL,'r'
		breq	showReg01
		cpi	argVL,LFCR
		breq	showReg0

showReg99:	rcall	showHeadLine
showReg9:	rcall	storeInBuffer	
		rcall	printBuffer
showReg7:	rjmp	mainLoop

showReg01:	rcall	showHeadLine
showReg0:	
showReg4:	rcall	storeInBuffer		; cpu in buf
		rcall	printBuffer		; print buf		
showReg1:	rcall	crConOut		; carriage return
		ldi	argVL, SHOWREGBUFSTARTPOS	;set the cursor to first editable position -> r24
		rcall	setCursorXRight
		ldi	YL, lo8(RZEICHENBUFFER+SHOWREGBUFSTARTPOS)		;initalize Position
		ldi	YH, hi8(RZEICHENBUFFER+SHOWREGBUFSTARTPOS)	; 	Y editable buf pos
showReg2:	rcall	setFGRed
		rcall	conControlIn	; get char
		cpi	argVL,0x21
		brlt	showReg3	; control or space
showReg77:	brtc	showReg7	; non hex back to mainloop
		ld	argVH,Y		;old value
		cpi	argVL,'2'
		sbrc	argVH,7		; write the hex
		brsh	showReg7	; back to mainLoop
		rcall	conOut
		andi	argVH,0x80
		or	argVL,argVH
		st	Y+,argVL
showReg21:	cpi	YL,lo8(RZEICHENBUFFER+SHOWREGBUFLENGTH)
		brne	showReg20
		sbiw	YL,1
		rcall	cursorBack
		breq	showReg2

showReg20:	ld	argVL,Y
		cpi	argVL,' '
		brne	showReg2
		adiw	YL,1
		rcall 	cursorFor
		rjmp	showReg21

showReg22:	cpi	YL,lo8(RZEICHENBUFFER)
		breq	showReg2
showReg23:	sbiw	YL,1
		rcall	cursorBack
		ld	argVL,Y
		cpi	argVL,' '
		brne	showReg2
		rjmp	showReg23

showReg24:	adiw	YL,1
		rcall	cursorFor
		rjmp	showReg21

showReg3:	rcall	switchCase	; control or space
.byte		LFCR
.word		pm(showRegEnd)
.byte		CURSORLEFT
.word		pm(showReg22)
.byte		CURSORRIGHT
.word		pm(showReg24)
.byte		0
.word		pm(mainLoop)
.align 1

 
showRegEnd:		rcall	restoreCPU
			rjmp	mainLoop

storeInBuffer:		ldi	YL, lo8(RZEICHENBUFFER)		;initalize Buffer
			ldi	YH, hi8(RZEICHENBUFFER)
			lds	argVH,LASTPC+1			;store the string
			lds	argVL,LASTPC
			rcall	save4Hex
			ldi	loop, 4+12+1+1			; 12 for dissass
			rcall	saveSpaces		
			lds	argVH,USERSREG
			ldi	loop,8				;print statusRegs
storeInBuffer2:		add	argVH,argVH
			ldi	argVL,'1'+0x80			; only 0 or 1
			brcs	storeInBuffer1
			dec	argVL				; '0'
storeInBuffer1:	 	st	Y+,argVL
		 	dec 	loop
			brne	storeInBuffer2
			lds	argVL,USERRAMPZ
			andi	argVL,1
			subi	argVL,-'0'+0x80
			st	Y+,argVL
			rcall	saveSpace
			lds	argVH,USERSP+1
			lds	argVL,USERSP
			rcall	save4Hex
			lds	argVH,REG+26+1
			lds	argVL,REG+26+0
			rcall	save4Hex
			lds	argVH,REG+28+1
			lds	argVL,REG+28+0
			rcall	save4Hex
			lds	argVH,REG+30+1
			lds	argVL,REG+30+0
			rcall	save4Hex
			rcall	saveSpace
			rcall	saveSpace
			ldi	XL,lo8(REG+16)			; lo von Register - Adresse in YL
			ldi 	XH,hi8(REG+16)			; hi von Register-Adresse in YH
storeInBuffer3:		ld	argVL,X+
			rcall	save2Hex
			cpi	XL,32-6
			brne	storeInBuffer3
			ret

printBuffer:		rcall setFGBlack
			rcall	crConOut
			ldi	XL,lo8(REG+16)			; lo von Register - Adresse in YL
			ldi 	XH,hi8(REG+16)			; hi von Register-Adresse in YH
			ldi	YL, lo8(RZEICHENBUFFER)
			ldi	YH, hi8(RZEICHENBUFFER)
			ldi	loop, SHOWREGBUFLENGTH
printBuffer1:		ld	argVL, Y+
			andi	argVL,0x7f
			rcall	conOut			;print the hole string
			dec	loop
			brne	printBuffer1
			rcall	setFGGreen			; Farbe setzen
			rcall 	spaceConOut	
printBuffer2:		ld	argVL,X+
			rcall	asciiConOut
			cpi	XL,32-6
			brne	printBuffer2
			ldi	argVL,'\r'
			rcall	conOut
			lds	argVH,LASTPC+1
			lds	argVL,LASTPC+0
			rcall	addrConOut
			rcall	spaceConOut
			rjmp	disAss

; bxxx xxxx  -> b==1 -> bin, 0x20 ->immutable 
save4Hex:		push	argVL
			mov	argVL,argVH
			swap	argVL
			andi	argVL,0x0f
			rcall	hex2Ascii
			st	Y+, argVL
			mov	argVL,argVH
			andi	argVL,0x0f
			rcall	hex2Ascii
			st	Y+, argVL
			pop	argVL
save2Hex:		push	argVL
			swap	argVL
			andi	argVL,0x0f
			rcall	hex2Ascii
			st	Y+, argVL
			pop	argVL
save1Hex:		andi	argVL,0x0f
			rcall	hex2Ascii
			st	Y+, argVL
saveSpace:		ldi	argVL,' '	; immutable
			st	Y+, argVL
			ret
saveSpaces:		rcall	saveSpace
			dec	loop
			brne	saveSpaces
			ret

restore4Hex:		adiw	YL,1		; over space
			rcall	restore2Hex
			mov	loop,argVL	; temp reg now
			rcall	restore2Hex
			mov	argVH,loop
			ret
restore2Hex:		rcall	restore1Hex
			swap	argVL
			mov	argVH,argVL
			rcall	restore1Hex
			or	argVL,argVH
			ret

restore1Hex:		ld	argVL,Y+
			rcall	ascii2Hex
			ret

restoreCPU:		ldi	YL, lo8(RZEICHENBUFFER-1)		;initalize Buffer
			ldi	YH, hi8(RZEICHENBUFFER-1)
			rcall	restore4Hex
			sts	LASTPC+1,argVH
			sts	LASTPC,argVL
			adiw	YL,4+12+1+1+1			; skip 12 for dissass
			ldi	loop,8
			ldi	argVL,0
restoreCPU1:		ld	argVH,Y+
			subi	argVH,'0'+0x80
			add	argVL,argVL
			add	argVL,argVH
			dec	loop
			brne	restoreCPU1
			sts	USERSREG,argVL
			ld	argVH,y+
			subi	argVH,'0'+0x80
			sts	USERRAMPZ,argVH
			rcall	restore4Hex
			sts	USERSP+1,argVH
			sts	USERSP,argVL
			rcall	restore4Hex
			sts	REG+26+1,argVH
			sts	REG+26+0,argVL
			rcall	restore4Hex
			sts	REG+28+1,argVH
			sts	REG+28+0,argVL
			rcall	restore4Hex
			sts	REG+30+1,argVH
			sts	REG+30+0,argVL
			adiw	YL,2+1			;skip 2 spaces and go to next valid char
			ldi	XL,lo8(REG+16)		; lo von Register - Adresse in YL
			ldi 	XH,hi8(REG+16)		; hi von Register-Adresse in YH
restoreCPU3:		rcall	restore2Hex
			st	X+,argVL
			adiw	YL,1			; space
			cpi	XL,lo8(REG+16+10)
			brne	restoreCPU3
			ret
	

ShowRegister:		
	rcall		setFGRed			; Farbe setzen
					rcall		outFlashText
.string	"\rPC   I T H S V N Z C PZ SP   X    Y    Z    Reg:0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5\r\n"
.align 1
						lds		argVH,USERPC+1
						lds		argVL,USERPC+0
						rcall 	adrConOut
						rcall		spaceConOut
						lds		argVH,USERSREG
						ldi		loop,8
ShowReg3:			add	argVH,argVH
						ldi		argVL,'1'
						brcs	EinsConOut
NullConOut:			dec	argVL
EinsConOut:			rcall 	conOut
						rcall 	spaceConOut
		 				dec 	loop
						brne	ShowReg3
						lds		argVL,USERRAMPZ
						rcall 	byteConOut
						rcall  	spaceConOut
						lds		argVH,(USERSP+1)
						lds		argVL,USERSP+0
						rcall 	adrConOut
						rcall	spaceConOut
						lds		argVH,(REG+26+1)
						lds		argVL,REG+26+0
						rcall 	adrConOut
						rcall		spaceConOut
						lds		argVH,(REG+28+1)
						lds		argVL,REG+28+0
						rcall 	adrConOut
						rcall		spaceConOut
						lds		argVH,(REG+30+1)
						lds		argVL,REG+30+0
						rcall 	adrConOut
						rcall		spaceConOut
//						rcall		outFlashText
//.string	"\n\rReg:0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5  6 7 8 9 0 1\r\n    "
//.align 1
						ldi		argVL,4
						rcall	setCursorXRight
						ldi		YL,lo8(REG)			; lo von Register - Adresse in YL
						ldi 	    YH,hi8(REG)			; hi von Register-Adresse in YH
ShowReg0:					sbrc	YL,3
						rcall 	setFGGreen
						ld		argVL,Y+
						rcall		 byteConOut
						cpi 		YL,0x20-6
						brne	ShowReg0
						ldi		YL,lo8(REG)			; lo von Register - Adresse in YL
						rcall		setFGBlack			; Farbe setzen
						rcall 	spaceConOut	
ShowReg1:			ld		argVL,Y+
						rcall		 asciiConOut
						cpi		YL,0x20
						brne	ShowReg1
						rjmp mainLoop
