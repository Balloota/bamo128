/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
#include	<avr/io.h>
#include "defines.asm"
#include "boarddefines.h"
// autor: 			Ines Moosdorf
// date of creation:		07.03.2006
// date of last modification: 	10.03.2006
// inputs:			sta in X (26=Low, 27=high)
//	  			enda in Y (28=low, 29=high)
//	  			desta in Z (30=l, 31=h)
// outputs:
// affected regs. flags:	R17, R18, R24, Z,C,N,V,H,S
// used subroutines:		EEPROMWrite, EEPROMRead
// changelog: 			04.06.2006 - Markennamen geaendert


.global copy
.global uploadwrite
//.section text1
copy:			rcall	echo
			rcall	switchCase
			.byte	's'
			.word	pm(copySramTo)
			.byte	'e'
			.word	pm(copyEepromTo)
			.byte	'f'
			.word	pm(copyFlashTo)
			.byte	0
			.word	pm(mainLoop)
.align 1					
copySramTo:		rcall	echo
			rcall	switchCase
			.byte	's'
			.word	pm(sRamCopy)
			.byte	'e'
			.word	pm(sRamEEpromCopy)
			.byte	'f'
			.word	pm(sRamFlashCopy)
			.byte	0
			.word	pm(mainLoop)
.align 1
copyEepromTo:		rcall	echo
			rcall	switchCase
			.byte	'e'
			.word	pm(eEpromCopy)
			.byte	's'
			.word	pm(eEpromSRamCopy)
			.byte	0
			.word	pm(mainLoop)
.align 1
copyFlashTo:		rcall	echo	
			rcall		conInAdrSupWS		// test for valid addresses!!
			mov		ZL,YL				//sta
			mov		ZH,YH
			rcall		spaceConOut
			rcall		conInAdrSupWS
			mov		XL,YL				// endadr
			mov		XH,YH
			rcall 		spaceConOut
			rcall		conInAdrSupWS	// destadr			
copyFlashTosRam3:	push	YL
			push	YH
			mov	YL,ZL
			mov	YH,ZH
			rcall	getFlashWord			// in argVL,argVH
			pop	YH
			pop	YL
			cp		XL,ZL
			cpc		XH,ZH
			breq	sRamReturn
			adiw	ZL,1
			push	argVL
			mov	argVL,argVH			// big endian first !!
			rcall		setSRamByte
			adiw	YL,1
			pop	argVL
			rcall		setSRamByte
			adiw	YL,1
			rjmp	copyFlashTosRam3

	; s
.align 1
sRamCopy:		rcall		conInAdrSupWS		// test for valid addresses!!
			mov		XL,YL				//sta
			mov		XH,YH
			rcall			spaceConOut
			rcall		conInAdrSupWS
			mov		ZL,YL				// endadr
			mov		ZH,YH
			rcall 		spaceConOut
sRamCopy2:		rcall		conInAdrSupWS	// destadr			
sRamCopy3:		push	YL
			push	YH
			mov	YL,XL
			mov	YH,XH
			push	ZH
			push	ZL
			rcall		getSRamByte
			pop	ZL
			pop	ZH
			adiw	XL,1
			pop	YH
			pop	YL
			push		ZH
			push ZL
			rcall		setSRamByte
			pop	ZL
			pop	ZH
			adiw	YL,1
			cp		XL,ZL
			cpc		XH,ZH
			brne	sRamCopy3
sRamReturn:		ret

sRamEEpromCopy:		rcall		conInAdrSupWS		// test for valid addresses!!
			mov		XL,YL				//sta
			mov		XH,YH
			rcall			spaceConOut
			rcall		conInAdrSupWS
			mov		ZL,YL				// endadr
			mov		ZH,YH
			rcall spaceConOut
			rcall		conInAdrSupWS	// destadr			
sRamEEpromCopy3:	push	YL
			push	YH
			mov	YL,XL
			mov	YH,XH
			push	ZH
			push	ZL
			rcall		getSRamByte
			pop	ZL
			pop	ZH
			adiw	XL,1
			pop	YH
			pop	YL
			rcall		setEEPromByte
			adiw	YL,1
			cp		XL,ZL
			cpc		XH,ZH
			brne	sRamEEpromCopy3
sRamEnd:
sRamFlashEnd:		ret		

//csf
sRamFlashCopy:	rcall	outFlashText
.string		"dangerous!!!\t"
.align 1
		rcall	conInAdrSupWS		// test for valid addresses!! < 0x7fff
		movw	r4,YL			// sram sta
		rcall	spaceConOut
		rcall	conInAdrSupWS		// endadr im sRam
		movw	XL,YL			// endadr in X, staadr in Z
		cp	XL,r4
		cpc	XH,r5
		brcs	sRamFlashEnd		// endadr > staadr
		sub	XL,r4
		sbc	XH,r5			// length in X in bytes
sRamFlashCopy3: rcall 	spaceConOut
		rcall	conInAdrSupWS		// destadr in Y
sRamFlashCopy1:	movw	ZL,YL			// flash address in Z n words
		movw	YL,r4			; sta sRam in Y in bytes
		rjmp	writeSpmBlock

CopyTxtToRam:			pop	ZH				; write text from text segment untested!!!
							pop	ZL				; get flash-textaddress->Initialize Z-pointer
							LSL	ZL
							ROL	ZH
							CLR	mpr
							brcc	CopyTxtToRam0
							inc		mpr
CopyTxtToRam0:			out		_SFR_IO_ADDR(RAMPZ),mpr
CopyTxtToRam2:			elpm	argVL, Z+ 			; from Z(RAMPZ) to Y anzahl in looplo
							st		Y+,argVL				; max 256 byte
							dec		loop
							brne	CopyTxtToRam2
							ROR	mpr
							ROR	ZH
							ROR	ZL
							ijmp
								
eepromWriteTest:			ldi		ZH,hi8(pm(eeprom))
							ldi		ZL,lo8(pm(eeprom)) 
							CLR  	r4
							LSL	ZL				; what ist with txt in address 0,fff ??
							ROL 	ZH				; no  ISR-save
							brcc	nn
							inc		r4			; alles auf die schnelle		#######################
nn:							out		_SFR_IO_ADDR(RAMPZ),r4
							ldi		r17,0
							ldi		r18,0
weiter:						elpm	argVL, Z+
							rcall		setEEPromByte
next:						inc		r18
							breq	fertig
							rjmp	weiter
fertig:						rcall	outFlashText
.string	"\r\nBytes fuer NanoVM in EEPROM geschrieben\r\n"
.align 1
							ret





eEpromSRamCopy:rcall		conInAdrSupWS		// test for valid addresses!!
					mov		XL,YL				//sta
					mov		XH,YH
					rcall			spaceConOut
					rcall		conInAdrSupWS
					mov		ZL,YL				// endadr
					mov		ZH,YH
					rcall	 		spaceConOut
					rcall		conInAdrSupWS	// destadr			
eEpromSRamCopy3:		push	YL
					push	YH
					mov	YL,XL
					mov	YH,XH
					rcall		getEEPromByte
					adiw	XL,1
					pop	YH
					pop	YL
					push	ZL
					push	ZH
					rcall		setSRamByte
					pop	ZH
					pop	ZL
					adiw	YL,1
					cp		XL,ZL
					cpc		XH,ZH
					brne	eEpromSRamCopy3
					ret

eEpromCopy:		rcall		conInAdrSupWS		// test for valid addresses!!
eEpromCopy1:	mov		XL,YL				//sta
					mov		XH,YH
					rcall		conInAdrSupWS
					mov		ZL,YL				// endadr
					mov		ZH,YH
eEpromCopy2:	rcall		conInAdrSupWS	// destadr		
eEpromCopy3:	push	YL
					push	YH
					mov	YL,XL
					mov	YH,XH
					rcall		getEEPromByte
					adiw	XL,1
					pop	YH
					pop	YL
					rcall		setEEPromByte
					adiw	YL,1
					cp		XL,ZL
					cpc		XH,ZH
					brne	eEpromCopy3
					ret
eeprom:
