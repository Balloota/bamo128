/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/

/*echo;		conOut;	conIn;	conStat; conControlIn
hexConOut; byteConOut, adrConOut, asciiConOut,hex2AsciiDecConOut
conIn2HexSupWS; conIn2Hex, ascii2Hex, conInAdrSupWS, conInAdr, conInByteSupWS, conInAdr
eatWhiteSpaces; conInByteBit
 ascii2Hex; hex2Ascii;conver2LowerCase; asciiDec2Hex; testHex


/************************************************************************************************************/
// revisited bh
// affected: zero-flag, retVL == argVL
#include	<avr/io.h>
#include "boarddefines.h"
#include "defines.asm"
.global	echo
.global	conOut
.global	serOut
.global	conIn
.global	serIn
.global	conStat
.global	serStat
.global conControlIn
.global conControl
.global conControlEscape
.global	addrConOut
.global	byteConOut
.global	hexConOut
.global	asciiConOut
.global conIn2HexSupWS
.global	conIn2Hex
.global	ascii2Hex
.global	eatWhiteSpaces
.global	conInByte
.global	conInByteSupWS
.global conInPCSupWSTestCR
.global	conInADRSupWSTestCR
.global conInAdrSupWSTestCR
.global	conInAdrSupWS
.global	conInAdr
.global hex2AsciiDecConOut
.global asciiDec2Hex
.global	testHex
.global	hex2Ascii
.global	convert2LowerCase
.global waitForKeyStroke
/*.global	decByteConOut
decByteConOut: 	push	XL		; einer
					mov	XL,argVL
					ldi		argVL,-1	; hunderter
decByteConOut0:	inc		argVL
					subi	XL,100
					brge	decByteConOut0
					subi	XL,-100
					cpi		argVL,0
					set
					brne	decByteConOut2
					rcall		hexConOut
					clt
decByteConOut2:	ldi		argVL,-1
decByteConOut1:	inc		argVL
					subi	XL,10
					brge	decByteConOut1
					subi	XL,-10
					cpi		argVL,0
					brne	decByteConOut3
					brtc	decByteConOut4
decByteConOut3:	rcall		hexConOut
decByteConOut4:	mov	argVL,XL
					rcall		hexConOut
					pop	XL
					ret

/**/				
echo:		rcall 	serIn				; byte in char
conOut:
serOut:		SEROUTMACRO
		ret	

conIn:
serIn:		rcall 	serStat				; byte in char
		brtc	serIn
		SERINMACRO
		ret

conStat:
serStat:	set
#ifdef ARDUINOMEGA
		push	argVL
#endif
		SERSTATMACRO
		clt
#ifdef ARDUINOMEGA
		pop	argVL
#endif
conControlEnd:	ret

waitForKeyStroke: push	YL
		push	YH
		ldi	argVL,0
		ldi	argVH,48//128//32//8//64//2 // adjust it
		ldi	YL,0
		ldi	YH,0
waitForKeyStroke1: rcall conStat
		brtc	waitForKeyStroke3
		inc	argVL
		rjmp	waitForKeyStroke2
waitForKeyStroke3: adiw	YL,1		// wait loop
		brne	waitForKeyStroke1
		dec	argVH
		brne	waitForKeyStroke1
waitForKeyStroke2: pop	YH
		pop	YL
		ret
		
/**************************************************************************************************************/
// bh
// affected: all Flags
// outputs: argVL, T -Flag (hex/nonhex) 
conControlIn:				rcall	conIn
							rcall	convert2LowerCase
							cpi		argVL,0x20				; space
							brlt		conControl
							rjmp	testHex				; T flag set/clear and end
conControl:				rcall		switchCase
.byte						DEL
.word						pm(conControlDel)
.byte						ESCAPE
.word						pm(conControlEscape)
.byte						0
.word						pm(conControlEnd)
.align 1

conControlEscape:		rcall		conIn					;ESC + ..

							cpi		argVL,'['					; [
							brne	conControl0End		; jetzt weiss ich nicht weiter?
							rcall		conIn
							cpi		argVL,'['
							breq	conControlKlKl		;[[
							cpi		argVL,'5'
							breq	conControlPageUp
							cpi		argVL,'6'
							breq	conControlPageDown
							subi	argVL,'A'-1
							cpi		argVL,CURSORUP					;A -> ret 1 cursor up
							breq	conControlEnd
							cpi		argVL,CURSORDOWN					;B-> ret 2 cursor down
							breq	conControlEnd
							cpi		argVL,CURSORRIGHT					;C-> ret 3 cursor right
							breq	conControlEnd
							cpi		argVL,CURSORLEFT					;D 	-> ret 4 cursor left
							breq	conControlEnd
conControlEsc0:			rcall		conIn				;  wait for ~
							cpi		argVL,'~'
							brne	conControlEsc0
							rjmp	conControl0End

conControlKlKl:			rcall	conIn
conControl0End:			clr		argVL
							ret
conControlPageUp:		rcall		conIn					;~
							ldi		argVL,PAGEUP						; '5' -> ret 5 page up
							ret
conControlPageDown:	rcall		conIn					; ~'
							ldi		argVL,PAGEDOWN					; 6' -> ret 6 page down
							ret

conControlDel:			ldi		argVL,DELETE
							ret
/***************************************************************************************************************/
// input: argVH,argVL
//affected:	Flags	
addrConOut:				push	argVL
							mov	argVL,argVH
							rcall	byteConOut
							pop	argVL
/************************************************************************************************************/	
// author:  			Tilo Kussatz
// date of creation: 		07.03.2006
// date of last modification:	10.03.2006
// inputs:			argVL  byte (2 hex zahlen)
// outputs:			-zwei bytes als ascii nach conOut
// affected :	-Flags
// used subroutines:		byteToAscii, conOut
byteConOut:	push	argVL
		swap	argVL
		rcall	hexConOut			;obere Bits umwandeln und in
		pop	argVL
/*****************************************************************************************/
// input: argVL (hex)
// affected: 	Flags
hexConOut:	push	argVL
		rcall	hex2Ascii
		rcall	conOut
		pop	argVL
		ret

/***************************************************************************************************************/
// autor:  			Christian Schmidt
// date of creation: 		08.03.2006
// date of last modification	04.06.2006
// inputs:			argVL (byte)
// outputs:			als ein ascii zeichen nach conOut oder '.'
// affected :	Flags	
// changelog			04.06.2006 - Marken-Name bearbeitet
// bh
asciiConOut:	cpi	argVL,' '	
		brlo	asciiConOutPunkt
		cpi	argVL,0x80
		brlo	asciiConOut0
asciiConOutPunkt:ldi	argVL,'.'			; Steuerzeichen - Punktausgeben
asciiConOut0:	rjmp	conOut
/***************************************************************************************************************/
// autor:			Marek Müller
// date of creation: 		06.03.2006
// date of last modification: 	04.06.2006
// inputs:	Tastaturzeichen bis gueltiges Hexzeichen, sonts sprung zu mainloop
// outputs:			T-Flag if first non whitespace LFCR, else retVL als Hex, if non hex jump to mainLoop
// affected regs. flags:
// changelog:			04.06.2006 - Markennamen geaendert
; wird LFCR gedrueckt, wird T -Flag gesetzt, sonst rueckgesetzt und 0 in retVL -> return
; bei ungueltigen Zeichen sprung zu mainloop
conIn2HexSupWS:	rcall	eatWhiteSpaces		// space, tab
		set
		rjmp	ascii2Hex	
conIn2Hex:	set 
		rcall 	echo					// ohne eat WHITE spaces
ascii2Hex:	cpi	argVL,LFCR
		breq	conIn2HexEnd			// erstes non white space LFCR !!
		cpi	argVL,LF
		breq	conIn2HexEnd			// erstes non white space LFCR !!
		cpi	argVL,SPACE
		breq	conIn2HexEnd			// erstes non white space LFCR !!
		cpi	argVL,'0'
		brlo	conIn2Hex2				// control sequenze and ...
		clt
		rcall	convert2LowerCase
conIn2Hex1:	subi	argVL,'0'
		cpi	argVL,':'-'0'
		brlo	conIn2HexEnd
		subi	argVL,-'0'+'a'-10
		cpi	argVL,'g'-'a'+10
		brlo	conIn2HexEnd
conIn2Hex2:	rjmp	mainLoop
/***************************************************************************************************************/
// autor:						Marek Müller
// date of creation:		 		06.03.2006
// date of last modification: 	4.10.2006
// inputs: 						conIn zeichen
// outputs: 						ein nicht WHITEspace-Konsolenzeichen
// affected regs. flags:			T, argVL
// used subroutines:			conIn
// changelog:					04.06.2006 - Markennamen geaendert
// 4.10.06 bh ueberarbeitet
eatWhiteSpaces:			rcall		echo						;Zeichen wird eingelesen
							cpi 			argVL,TAB
							breq		eatWhiteSpaces
							cpi			argVL,SPACE
							breq		eatWhiteSpaces
conIn2HexEnd:	ret
/****************************************************************************************************************/
// autor:			Marek Müller
// date of creation: 		06.03.2006
// date of last modification: 	04.06.2006
// inputs:
// outputs:			Byte in retVL
// affected:	Flags
// used subroutines:		conIn2Hex
// changelog:			04.06.2006 - Markennamen geaendert
// ToDo: Fehlerbehebung, wenn weder Steuerzeichen noch korrektes Hex-Zeichen eingegeben wurde
; wird LFCR gedrueckt, wird T -Flag gesetzt, sonst rueckgesetzt
; bei ungueltigen Zeichen sprung zu mainloop
conInByte:					clr		argVL
							rjmp	conInByte2
conInByteSupWS:	rcall	conIn2HexSupWS
		brts	conInByteEnd1	; first non whitespace is lfcr		
conInByte2:	push	retVH
		mov	retVH,retVL
conInByte1:	rcall	conIn2Hex	; ohne eat whitepsaces
		brts	conInByteEnd					;LFCR -> ENDE 
		swap	retVH
		andi	retVH,0xf0		; 4.1.10 bh
		or	retVH,retVL
		rjmp	conInByte1
conInByteEnd:	mov	retVL,retVH
		pop	retVH
conInByteEnd1:	ret
/****************************************************************************************************************/
// autor:			Mathias Boehme
// date of creation: 		04.06.2006
// date of last modification: 	04.06.2006
// inputs:
// outputs:			
// affected regs. flags:	
// used subroutines:		conInByte
// changelog:
// YH,YL enthalten 16 Bit adr
// wenn erstes sinnvolles Zeichen LFCR-> YH,YL unchanged sonst 16 Bit Adresse
// jeder Fehler springt zu mainLoop
conInPCSupWSTestCR:	lds			YL,USERPC
								lds			YH,USERPC+1
								rcall		conInAdrSupWSTestCR			; Adresse zum Anzeigen Abfragen < 0x8000 ???
								sts			USERPC,YL
								sts			USERPC+1,YH
								ret
								
conInADRSupWSTestCR:	lds			YL,LASTADR
								lds			YH,LASTADR+1
								rcall		conInAdrSupWSTestCR			; Adresse zum Anzeigen Abfragen < 0x8000 ???
								sts			LASTADR,YL
								sts			LASTADR+1,YH
								ret

conInAdrSupWSTestCR:	brts	conInAdrEnd	// LFCR - entry point
conInAdrSupWS:		rcall 	conIn2HexSupWS			// entry point
			brts	conInAdrEnd				// LFCR
			clr	YH
			clr	YL
conInAdr1:	add	YL,YL		// entry point Y not  reset!!
		adc	YH,YH
		add	YL,YL
		adc	YH,YH
		add	YL,YL
		adc	YH,YH
		add	YL,YL
		adc	YH,YH						
		or	YL,retVL
conInAdr:	rcall	conIn2Hex
		brtc	conInAdr1
conInAdrEnd:	ret

/****************************************************************************************************************/
// argVL <0x64, ausgabe an conOut als decimal ascii Zahlen, print leadind zero
// affected: Flags
hex2AsciiDecConOut:	push	argVH
							push	argVL
							pop	argVH
							ldi		argVL,0
hex2AsciiDecConOut2:	subi	argVH,10
							brlo	hex2AsciiDecConOut1
							inc		argVL
							rjmp	hex2AsciiDecConOut2
hex2AsciiDecConOut1:	subi	argVH,-10
//							cpi		argVL,0		; suppress leading zeros
//							breq	hex2AsciiDecConOut3
							subi	argVL,-'0'
							rcall	conOut				
hex2AsciiDecConOut3:	subi	argVH,-'0'
							mov	argVL,argVH
							pop	argVH
							rjmp	conOut	
/****************************************************************************************************************/
// ascii in argVH, argVL, result in retVL			
asciiDec2Hex:				subi	argVL,'0'-1
							subi	argVH,'0'
							inc		argVH
asciiDec2Hex1:			subi		argVL,-10
							dec	argVH			
							brne	asciiDec2Hex1
							ret
/*********************************************************************************************************/
// T=1 -> hex, sonst 0
// affected: Flags
testHex:	push	argVL
		set
		subi	argVL,'0'
		cpi	argVL,':'-'0'
		brlo	testHexEnd
		subi	argVL,-'0'+'a'
		cpi	argVL,'g'-'a'
		brlo	testHexEnd
		clt
testHexEnd:	pop	argVL
		ret
/***************************************************************************************************************/
// affected: flags
hex2Ascii:	andi	argVL,0x0f
		subi	argVL,-'0'
		cpi	argVL,':'
		brlo	hex2AsciiEnd
		subi	argVL,':'-'a'
hex2AsciiEnd:	ret
/***************************************************************************************************************/
// autor:  			Christian Schmidt
// date of creation: 		06.03.2006
// date of last modification	04.06.2006
// inputs:			argVL
// outputs:			retVL
// affected : Flags	
// changelog			04.06.2006 - Markennamen geaendert
convert2LowerCase:		cpi		argVL,'A'	; wandelt alle Buchstaben in Kleinbuchstaben um
							brlo	convert2LowerCaseEnd	
							cpi		argVL,'['
							brge	convert2LowerCaseEnd
							subi	argVL,-'a'+'A'
convert2LowerCaseEnd:	ret
/****************************************************************************************************************/
