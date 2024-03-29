/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/

#include	<avr/io.h>
#include "defines.asm"
.global beep
.global home
.global clearScreen
.global intensiveON
.global intensiveOFF
.global	blinkON
.global	blinkOFF
.global	saveCursor
.global	restoreCursor
.global	clearScreenFromPosition
.global	clearLineFromPosition
.global	clearLine
.global	cursorOn
.global	cursorOff
.global	cursorDown
.global	cursorUp
.global	cursorBack
.global	cursorFor
.global	lfConOut
.global	lfcrConOut
.global	crConOut
.global	spaceConOut
.global	adrConOut
.global	setCursorXLeft
.global	setCursorXRight
.global	setCursorXY
.global	setCursorYUp
.global	setCursorYDown
.global	setFGGreen
.global	setFGBlack
.global	setFGBlue
.global	setFGRed
.global	setFGWhite
.global	setFGColor
.global	setBGColor
.global	getCursorXY

//.section text1
//beep:							ldi		argVL,BELL
//								rjmp	conOut
home:							rcall 	escKlammer
								ldi		argVL,'H'
								rjmp 	conOut
								ret
clearScreen: 					rcall	outFlashText
.string							"\033[2J"
.align 1
								ret
//intensiveON:					rcall	outFlashText			// //not testet yet
//.string							"\033[1m"
//.align 1
								ret
//intensiveOFF:					rcall	outFlashText
//.string							"\033[4m"
//.align 1
//								ret
//blinkON:						rcall	outFlashText
//.string							"\033[5m"
//.align 1
//								ret
//blinkOFF:						rcall	outFlashText		// //not testet yet
//.string							"\033[6m" //??
//.align 1
//								ret
saveCursor:					rcall	outFlashText
.string							"\033[s"
.align 1
								ret
restoreCursor:					rcall	outFlashText
.string							"\033[u"
.align 1
								ret								
clearScreenFromPosition:	rcall 	escKlammer
				ldi		argVL,'J'
				rjmp 	conOut

clearLineFromPos:		rcall 	escKlammer
				ldi	argVL,'K'
				rjmp 	conOut

clearLine:			rcall	outFlashText
.string				"\033[2K"
.align 1
				ret
cursorOn:			rcall	outFlashText
.string				"\033[?25h"				//h??
.align 1
				ret
cursorOff:			rcall	outFlashText
.string				"\033[?25h"				//h??!!
.align 1
				ret
cursorDown:			rcall 	escKlammer
				ldi		argVL,'B'
				rjmp 	conOut

cursorUp:			rcall 	escKlammer
				ldi		argVL,'A'
				rjmp 	conOut

cursorBack:			rcall 	escKlammer
				ldi		argVL,'D'
				rjmp 	conOut

cursorFor:			rcall 	escKlammer
				ldi		argVL,'C'
				rjmp 	conOut

lfConOut:			push	argVL
				ldi		argVL,LF
lfConOutEnd:			rcall	conOut
				pop	argVL
				ret

lfcrConOut:			rcall	lfConOut
crConOut:			push	argVL
				ldi		argVL,CR
				rjmp	lfConOutEnd

spaceConOut:			push 	argVL				; argVL auf den Stack retten
				ldi		argVL,SPACE
				rjmp	lfConOutEnd

adrConOut:			push	argVL	; gibt eine Adresse in argVH:argVLWL mit Hilfe von byteConOut aus
				mov	argVL,argVH
				rcall	byteConOut
				pop	argVL
				rjmp	byteConOut								

	;Cursor argVL Zeichen nach links/rechts argVL als hex 
setCursorXLeft:			rcall 	escKlammer
				rcall	hex2AsciiDecConOut
				ldi		argVL,'D'
				rjmp 	conOut
setCursorXRight:		rcall 	escKlammer
				rcall	hex2AsciiDecConOut
				ldi		argVL,'C'
				rjmp 	conOut
								
escKlammer:			rcall	outFlashText
.string				"\033["
.align 1
				ret

// argVL-> x, argVH->y als hex von 0 bis..
;**printf("%c[%d;%dH",27,y+1,x+1);
setCursorXY:			push 	argVL
				rcall	escKlammer
				mov	argVL,argVH
				inc		argVL
				rcall	hex2AsciiDecConOut
				ldi		argVL,';'
				rcall	conOut
				pop	argVL
				inc		argVL
				rcall	hex2AsciiDecConOut
				ldi		argVL,'H'
				rjmp	conOut

setCursorYUp:			rcall 	escKlammer
				rcall	hex2AsciiDecConOut
				ldi		argVL,'A'
				rjmp 	conOut

setCursorYDown:			rcall 	escKlammer
				rcall	hex2AsciiDecConOut
				ldi		argVL,'B'
				rjmp 	conOut

/************************************************************************************************************************************************/
// autor:  			Christian Schmidt
// date of creation: 		08.03.2006
// date of last modification	08.03.2006
// inputs:			argVL
// outputs:			
// affected regs. flags:	
// used subroutines:
// changelog
// Fontcolor
// background and Foreground
// argVL=0 - grün
// argVL=1 - weiß
// argVL=2 - schwarz
// argVL=3 - schwarz
// argVL=4 - rot
// argVL=5 - weiß	; eigentlich grau
	; Schriftfarbe aendern, alle danach geschriebenen Zeichen haben die Farbe
setFGGreen:			push 	argVL
				ldi		argVL,GREEN
setFGGreen0:			rcall	setFGColor
				pop	argVL
				ret

setFGBlack:			push	argVL
				ldi		argVL,BLACK
				rjmp	setFGGreen0

setFGBlue:			push	argVL
				ldi		argVL,BLUE
				rjmp	setFGGreen0
					
setFGRed:			push	argVL
				ldi		argVL,RED
				rjmp	setFGGreen0
setFGWhite:			push	argVL
				ldi		argVL,WHITE
				rjmp	setFGGreen0

setFGColor:			push	argVL				;Fontfarbe setzen
				rcall	escKlammer
				ldi		argVL,'3'
				rjmp	setBGColor1
								
// BackGround:
// argVL=0 - rosa BG
// argVL=1 - blauer BG
// argVL=2 - hellgrau
// argVL=3 - brauner BG
// argVL=4 - grüner BG
// argVL=5 - schwarzer BG 
; setzt die Hintergrundfarbe, alle danach geschriebenen Zeichen haben diese Farbe als Hintergrund
setBGColor:		push 	argVL
			rcall	escKlammer
			ldi	argVL,'4'
setBGColor1:		rcall 	conOut
			pop	argVL
			rcall 	conOut
			push	argVL
			ldi	argVL,'m'
			rcall	conOut
			pop	argVL
			ret
/*
// autor:  			Christian Schmidt, Mathias Boehme
// date of creation: 		09.03.2006
// date of last modification	18.06.2006
// inputs:			
// outputs:			Xwert in retVL, Ywert in retVH
// affected regs. flags:
// used subroutines:		conOut, conIn, testHex, dec2Hex
// changelog			04.06.2006 - Markennamen geaendert
//				16.06.2006 - Rueckgabe in retVL und retVH richtig gestaltet
//					   - String zur Rueckgabe der Cursor-Position mit eingebunden
//					   - Rueckgabestringverarbeitung vereinfacht
//					   - pushs/pops ueberarbeitet (es wurde der gerade erstellte Rueckgabewert gleich wieder ueberschrieben)
//				18.06.2006 - Stackabfrage statisch gestaltet, um unterschiedliche Positionsrueckgabe besser abzufangen
//					   - Positionen in gueltige Hexadezimalwerte umgewandelt
//
	; getCoursorXY Sendet einen String ("<ESC>[6n") an die Console, der dort eine ANSI/VT100-Funktion ausloest, die einen
	; String  " ESC[Zeile;SpalteR"  mit der aktuellen Cursorposition zurueckgibt.
getCursorXY:					rcall	outFlashText			// not testet yet
.string		"\033[6n"
.align 1
								push	XH
								rcall	conIn	//ESCAPE
								rcall	conIn	//[
								clr		argVH
getZeileLoop:					rcall	conIn	//1.ziffer
								cpi		argVL,';'
								breq	getSpalte
								rcall	ascii2Hex
								mov	XH,argVH
								add	argVH,argVH			// \*2
								add	argVH,argVH			//\*4
								add	argVH,XH				//\*5
								add	argVH,argVH			//\*10
								add	argVH,argVL
								rjmp	getZeileLoop
getSpalte:						push	argVH
getSpalteLoop:				rcall	conIn	//1.ziffer
								cpi		argVL,'R'
								breq	getCursorEnd
								rcall	ascii2Hex
								mov	XH,argVH
								add	argVH,argVH			// \*2
								add	argVH,argVH			//\*4
								add	argVH,XH				//\*5
								add	argVH,argVH			//\*10
								add	argVH,argVL
								rjmp	getSpalteLoop	
getCursorEnd:					pop	argVL				// Zeile
								pop	XH
								ret
*/