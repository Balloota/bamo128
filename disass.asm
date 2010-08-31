/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
// 21.3.07 first version
.global 	disAss
.global	dissass
#include <avr/io.h>
#include "boarddefines.h"
#include "defines.asm"


dissass:	rcall		conInADRSupWSTestCR			; ,LASTADR
			rcall		lfcrConOut
			ldi			XL,0x8
			movw		r22,YL						; PC
dissass0:	movw		argVL,r22
			rcall		adrConOut
			rcall		spaceConOut
			movw		YL,argVL
			rcall		getFlashWord					; instr
			rcall		adrConOut
			rcall		spaceConOut
			rcall		spaceConOut
			push		XL
			rcall		disAss1
			movw		YL,r22
			ADIW		YL,1
			movw		r22,YL
			sts			LASTADR,r22
			sts			LASTADR+1,r23
			rcall		lfcrConOut
			pop		XL
			dec		XL
			brne	dissass0
			ret
disAss:		movw	YL,argVL		//PC		
		movw	R22,YL			//PC
		rcall	getFlashWord
		rcall	adrConOut
		rcall 	spaceConOut
disAss1:		movw	R2,argVL		// instr
		ldi		YL,lo8(pm(iMaskiBits))
		ldi		YH,hi8(pm(iMaskiBits))
		clr		R4
		dec	r4
		clr		R5
disass0:	inc		R4	
		rcall	getFlashWord	//iMask
		and	argVL,R2
		and	argVH,R3
		movw	XL,argVL
		adiw	YL,1
		rcall	getFlashWord	//iBits
		adiw	YL,1
		cp	XL,argVL
		cpc	XH,argVH
		brne	disass0
		movw	R16,R4		// instrNumber
		add	R4,R4		;*2
		add	R4,	R16
		adc	R5,R17	;*3 
		ldi		YL,lo8(pm(iString))
		ldi		YH,hi8(pm(iString))
		add	YL,R4
		adc	YH,R5
		rcall	getFlashWord
		rcall		conOut
		mov	argVL,argVH
		rcall		conOut
		adiw	YL,1
		rcall	getFlashWord
			rcall		conOut
			mov	argVL,argVH
			rcall		conOut
			adiw	YL,1
			rcall	getFlashWord
			rcall		conOut
			mov	argVL,argVH
			rcall		conOut
// R2 instr, R22 -> PC, R16-iNumber
			mov	argVL,R16		; instrNumber
			rcall		switchCase
.byte		IMOVW
.word		pm(movwOp)
.byte		IMULS
.word		pm(movwOp)
.byte		IMULSU
.word		pm(mulsuOp)
.byte		IFMUL
.word		pm(mulsuOp)
.byte		IFMULS
.word		pm(mulsuOp)
.byte		IFMULSU
.word		pm(mulsuOp)
.byte		ICPC
.word		pm(cpcOp)
.byte		ISBC
.word		pm(cpcOp)
.byte		IADD
.word		pm(cpcOp)
.byte		ICPSE
.word		pm(cpcOp)
.byte		ICP
.word		pm(cpcOp)
.byte		ISUB
.word		pm(cpcOp)
.byte		IADC
.word		pm(cpcOp)
.byte		IAND
.word		pm(cpcOp)
.byte		IEOR
.word		pm(cpcOp)
.byte		IOR
.word		pm(cpcOp)
.byte		IMOV
.word		pm(cpcOp)
.byte		IMUL
.word		pm(cpcOp)
.byte		ICPI
.word		pm(cpiOp)
.byte		ISBCI
.word		pm(cpiOp)
.byte		ISUBI
.word		pm(cpiOp)
.byte		IORI
.word		pm(cpiOp)
.byte		IANDI
.word		pm(cpiOp)
.byte		ILDI
.word		pm(cpiOp)
.byte		ILDDZ
.word		pm(lddOp)
.byte		ILDDY
.word		pm(lddOp)
.byte		ISTDZ
.word		pm(stdOp)
.byte		ISTDY
.word		pm(stdOp)
.byte		ILDS
.word		pm(ldsOp)
.byte		ILDZP
.word		pm(ldzpOp)
.byte		ILPMZP
.word		pm(ldzpOp)
.byte		IELPMZP
.word		pm(ldzpOp)
.byte		ILDZM
.word		pm(ldzpOp)
.byte		ILPMZ
.word		pm(ldzpOp)
.byte		IELPMZ
.word		pm(ldzpOp)
.byte		ILDYP
.word		pm(ldzpOp)
.byte		ILDYM
.word		pm(ldzpOp)
.byte		ILDX
.word		pm(ldzpOp)
.byte		ILDXP
.word		pm(ldzpOp)
.byte		ILDXM
.word		pm(ldzpOp)
.byte		IPOP
.word		pm(ldzpOp)
.byte		ICOM
.word		pm(ldzpOp)
.byte		INEG
.word		pm(ldzpOp)
.byte		ISWAP
.word		pm(ldzpOp)
.byte		IINC
.word		pm(ldzpOp)
.byte		IASR
.word		pm(ldzpOp)
.byte		ILSR
.word		pm(ldzpOp)
.byte		IROR
.word		pm(ldzpOp)
.byte		IDEC
.word		pm(ldzpOp)
.byte		IPUSH
.word		pm(ldzpOp)
.byte		ISTS
.word		pm(stsOp)
.byte		ISTZP
.word		pm(ldzpOp)
.byte		ISTZP
.word		pm(ldzpOp)
.byte		ISTZM
.word		pm(ldzpOp)
.byte		ISTYP
.word		pm(ldzpOp)
.byte		ISTYM
.word		pm(ldzpOp)
.byte		ISTX
.word		pm(ldzpOp)
.byte		ISTXP
.word		pm(ldzpOp)
.byte		ISTXM
.word		pm(ldzpOp)
.byte		IJMP
.word		pm(jmpOp)
.byte		ICALL
.word		pm(jmpOp)
.byte		IJMP
.word		pm(ldsOp)
.byte		IADIW
.word		pm(adiwOp)
.byte		ISBIW
.word		pm(adiwOp)
.byte		ICBI
.word		pm(cbiOp)
.byte		ICBIC
.word		pm(cbiOp)
.byte		ISBI
.word		pm(cbiOp)
.byte		ISBIS
.word		pm(cbiOp)
.byte		IIN
.word		pm(inOp)
.byte		IOUT
.word		pm(outOp)
.byte		IRJMP
.word		pm(rjmpOp)
.byte		IRCALL
.word		pm(rjmpOp)
.byte		IBRLO
.word		pm(brloOp)
.byte		IBREQ
.word		pm(brloOp)
.byte		IBRMI
.word		pm(brloOp)
.byte		IBRVS
.word		pm(brloOp)
.byte		IBRLT
.word		pm(brloOp)
.byte		IBRHS
.word		pm(brloOp)
.byte		IBRTS
.word		pm(brloOp)
.byte		IBRIE
.word		pm(brloOp)
.byte		IBRCC
.word		pm(brloOp)
.byte		IBRNE
.word		pm(brloOp)
.byte		IBRPL
.word		pm(brloOp)
.byte		IBRVC
.word		pm(brloOp)
.byte		IBRGE
.word		pm(brloOp)
.byte		IBRHC
.word		pm(brloOp)
.byte		IBRTC
.word		pm(brloOp)
.byte		IBRID
.word		pm(brloOp)
.byte		IBLD
.word		pm(bldOp)
.byte		IBST
.word		pm(bldOp)
.byte		ISBRC
.word		pm(bldOp)
.byte		ISBRS
.word		pm(bldOp)
.byte		0
.word		pm(instrRet)
.align 1
// R2,R3 instr, R22 -> PC, R16-iNumber
bldOp:		movw	argVL,r2
			lsr		argVH
			ror		argVL
			lsr		argVL
			lsr		argVL
			lsr		argVL
			rcall	hex2AsciiDecConOut
			ldi		argVL,','
			rcall	conOut
			mov	argVL,r2
			andi	argVL,0x07
			rcall	hex2AsciiDecConOut					;sprintf(mnemonic+8,"R%d,0x%02X",D5,MBIT);
			rjmp	spaceConOut
brloOp:	lsr		r3
			ror		r2
			lsr		r3
			ror		r2
			asr		r2
			clr		r3
			sbrc	r2,7
			dec	r3
			movw	argVL,r22
			add	argVL,r2
			adc	argVH,r3
			adiw	argVL,1
			rcall	adrConOut							;sprintf(mnemonic+8,"0x%02X (0x%04X)",K7&0x7f,(addr+1+K7)&0xffff);
			rcall	spaceConOut
			rjmp	spaceConOut
rjmpOp:	
rcall	outFlashText
.string		" x"
.align 1
			movw	argVL,r2
			andi	argVH,0x0f
			sbrc	argVH,3
			ori		argVH,0xf0
			add	argVL,r22
			adc	argVH,r23
			adiw	argVL,1
			rjmp	adrConOut								;sprintf(mnemonic+8,"0x%03X (0x%04X)",K12&0xfff,(addr+1+K12)&0xffff);
inOp:		movw	argVL,r2
			swap	argVL
			andi	argVL,0x0f
			swap	argVH
			andi	argVH,0x10
			or		argVL,argVH
			rcall	hex2AsciiDecConOut		;sprintf(mnemonic+8,"R%d,0x%02X",D5,P6);
			rcall	outFlashText
.string		",px"
.align 1
			swap	r3
			asr		r3
			mov	argVL,r2
			andi	argVL,0x0f
			mov	argVH,r3
			andi	argVH,0xf0
			or		argVL,argVH
			rjmp	byteConOut

outOp:		mov	argVH,r3
			swap	argVH
			asr		argVH
			andi	argVH,0x30
			mov	argVL,r2
			andi	argVL,0x0f
			or		argVL,argVH
			rcall	byteConOut
			rcall	outFlashText
.string		",r"
.align 1
			mov	argVL,r2
			swap	argVL
			andi	argVL,0x0f
			mov	argVH,r3
			swap	argVH
			andi	argVH,0x10
			or		argVL,argVH
			rjmp	hex2AsciiDecConOut					;sprintf(mnemonic+8,"0x2X,R%d",P6,D5);
cbiOp:		mov	argVL,r2
			asr		argVL
			asr		argVL
			asr		argVL
			rcall	hex2AsciiDecConOut
			rcall	outFlashText
.string		","
			mov	argVL,r2
			andi	argVL,0x07
			rjmp	hex2AsciiDecConOut					;sprintf(mnemonic+8,"0x%02X,R%d",P5,MBIT);
adiwOp:	movw	argVL,r2
			swap	argVL
			andi	argVL,0x03		; sprintf(mnemonic+8,"R%d,0x%02X",D2,K6);
			add	argVL,argVL
			subi	argVL,-24
			rcall	hex2AsciiDecConOut
			rcall	outFlashText
.string		",x"
.align 1
			mov	argVL,r2
			andi	argVL,0xc0
			asr		argVL
			asr		argVL
			mov	argVH,r2
			andi	argVH,0x0f
			or		argVL,argVH
			rjmp	byteConOut
jmpOp:	rcall	outFlashText
.string		" x"
.align 1
			movw	YL,R22
			adiw	YL,1
			movw	r22,YL
			rcall	getFlashWord
			rjmp	adrConOut		
stsOp:		rcall	cursorBack
			rcall	cursorBack
			movw	YL,R22
			adiw	YL,1
			movw	r22,YL
			rcall	getFlashWord
			rcall	adrConOut
			rcall	outFlashText
.string		",r"
.align 1
			movw	argVL,r2
			swap	argVL
			andi	argVL,0x0f
			andi		argVH,0x01
			swap	argVH
			or	argVL,argVH
			rjmp		hex2AsciiDecConOut ;	sprintf(mnemonic+8,"0x%04X,R%d",flash[addr+1],D5);

ldzpOp:	movw	argVL,r2
			swap	argVL
			andi	argVL,0x0f
			andi	argVH,01
			swap	argVH
			or		argVL,argVH
			rcall	hex2AsciiDecConOut		;sprintf(mnemonic+8,"R%d",D5);
			rcall	outFlashText
.string		"    "
.align 1
			ret
ldsOp:		rcall	cursorBack
			rcall	cursorBack
			ldi		argVL,'r'
			rcall 	conOut
			movw	argVL,r2
			swap	argVL
			andi	argVL,0x0f
			swap	argVH
			andi	argVH,0x10
			or		argVL,argVH
			rcall		hex2AsciiDecConOut
			rcall	outFlashText
.string		",x"
.align 1
			movw	YL,R22
			adiw	YL,1
			movw	r22,YL
			rcall	getFlashWord
			rjmp	adrConOut			//		sprintf(mnemonic+8,"R%d,0x%04X",D5,flash[addr+1]);
lddOp:		rcall cursorBack
			movw	argVL,r2
			lsr		argVH
			ror		argVL
			lsr		argVL
			lsr		argVL
			lsr		argVL
			rcall	hex2AsciiDecConOut
			rcall	outFlashText
.string		",+x"
.align 1
			movw	argVL,r2
			sbrc	argVH,5
			ori		argVH,0x10
			rol		argVH
			andi	argVH,0b00111000
			andi	argVL,0b00000111
			or		argVL,argVH
			rjmp	byteConOut		//sprintf(mnemonic+8,"R%d,Y+%0x%X",D5,K5);
stdOp:		movw	argVL,r2
			sbrc	argVH,5
			ori		argVH,0x10
			rol		argVH
			andi	argVH,0b00111000
			andi	argVL,0b00000111
			or		argVL,argVH
			rcall	byteConOut
			rcall	outFlashText
.string		",r"
.align 1
			movw	argVL,r2
			lsr		argVH
			ror		argVL
			lsr		argVL
			lsr		argVL
			lsr		argVL
			rjmp	hex2AsciiDecConOut;		sprintf(mnemonic+8,"Y+0x%X,,R%d",K5,D5);
cpiOp:		mov	argVL,r2
			swap	argVL
			andi	argVL,0x0f
			ori		argVL,0x10
			rcall	hex2AsciiDecConOut
			ldi		argVL,','
			rcall	conOut
			ldi		argVL,'x'
			rcall	conOut
			swap	r3
			ldi		argVL,0xf0
			and	argVL,r3
			mov	argVH,r2
			andi	argVH,0x0f
			or		argVL,argVH
			rjmp	byteConOut			//sprintf(mnemonic+8,"R%d,0x%02x",D4U,K8);
mulsuOp:	mov	argVL,r2
			ori		argVL,0x88
			mov	r2,argVL					//sprintf(mnemonic+8,"R%d,R%d",D3U,R3U);
movwOp:	mov	argVL,R2		; low teil
			swap	argVL
			andi	argVL,0x0f
			lsl		argVL
			rcall	hex2AsciiDecConOut
			ldi		argVL,','
			rcall		conOut
			ldi		argVL,'r'
			rcall		conOut
			mov	argVL,R2		; low teil instr
			andi	argVL,0x0f
			lsl		argVL
			rjmp		hex2AsciiDecConOut	//sprintf(mnemonic+8,"R%d,R%d",D4,R4);
instrRet:	rcall	outFlashText
.string		"      \0"
.align 1
			ret	

cpcOp:	movw	argVL,r2
			lsr		argVH
			ror		argVL
			lsr		argVL
			lsr		argVL
			lsr		argVL
			andi	argVL,0x1f
			rcall	hex2AsciiDecConOut
			ldi		argVL,','
			rcall	conOut
			ldi		argVL,'r'
			rcall	conOut
			movw	argVL,r2
			andi	argVL,0x0f
			sbrc	r3,1
			ori		argVL,0x10
			rjmp	hex2AsciiDecConOut		//sprintf(mnemonic+8,"R%d,R%d",D5,R5);
