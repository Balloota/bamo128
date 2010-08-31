/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
#ifndef		__DEFINES__
#define		__DEFINES__

// Monitordefinitionen
#define		VERSION		"0.06"


#define		MONRAMBYTES	0x100

// CPU-state
#define 	MON		(BOARDRAMEND-MONRAMBYTES)

#define		REG		MON
#define		LASTADR		(MON+0x20)
#define		LASTCOMMAND	(MON+0x22)
#define		BREAKADDR	(MON+0x24)	// +2*MAXNUMBREAKPOINTS

#define		USERPC		(MON+0x36)	// +37, weil 16bit .. ProgramCounter
#define		SUPPRESSHEADLINE	(MON+0x38)
#define		ISSTEPORBREAK	(MON+0x3a)	// 0 go
#define		NUMSTEPS	(MON+0x3b)

#define		LASTPC		(MON+0x3c)
#define		USERRAMPZ	(MON+0x5b)	//   .. RAMPZ Register		005B
#define		USERSP		(MON+0x5d)	// +5e, weil 16bit StackPointer	005D
#define		USERSREG	(MON+0x5f)	//   .. StatusRegister		005F
//CPU-Zustand Ende
#define		SYSTIME	(MON+0x40)		// 4 Bytes
#define		ZEICHENBUFFER	(MON+0x60)	//  ..	Display 8 Zeichen a 8 Zeilen
#define		STACKMON	(BOARDRAMEND)	// stack for monitor from charonend abwärts
#define		STACKUSER	MON		// unter mon
#define		MAXNUMBRKPOINTS	8


#define		RZEICHENBUFFER	ZEICHENBUFFER
//(BOARDRAMEND-0x200)	//  .. Display 8 Zeichen a 8 Zeilen

#define		SHOWREGBUFLENGTH	84
#define		SHOWREGBUFSTARTPOS	79
;Constants

#define 	loop 		r17

// r2-r17 ->Calling subroutines leaves them unchanged
// Assembler subroutines are responsible for saving and restoring these registers, if changed. 
// Fixed registers (r0, r1):
// Often used for ﬁxed purposes:
// r0 - temporary register, can be clobbeRED by any code (except interrupt handlers which save it),
// may be used to remember something for a while within one piece of assembler code
// r1 - assumed to be always zero in any code, may be used to remember something for
// a while within one piece of assembler code, but must then be cleaRED after use

#define		mpr		r19

#define		argVL		r24			// word argVL low
#define		argVH		r25			// word argVL high
	
#define		retVL		r24			// word return value low
#define		retVH		r25			// word return value high

#define		zeroReg	r1			// always zero

// other regs r18-r31
// You may use them freely in assembler subroutines.
// Calling subroutines can clobber any of them - the rcaller is responsible for saving and restoring.
// ISR's must save all flags and used registers
// if you use subroutines in ISR's, study carefully which regs these use and save them 

// XL(r26), XH(r27), YL(r28),YH(r29),ZL(r30),ZH(r31)
// r29:r28 (Y pointer) is used as a frame pointer (points to local data on stack) if necessary.	

// stack von BOARDRAMEND-255 abwärts
// 256 Bytes vor BOARDRAMEND fuer Monitor reserviert

#define		BYTES(x)	((x)*2)


#define		SPACE		0x20
#define		BS				0x08
#define		TAB			0x09
#define		LF				0x0a
#define		VT				0x0b
#define		FF				0x0c
#define		CR				0x0d
#define		LFCR			'\r'			// 0xa!!!
#define		DEL			0x7F
#define		ESCAPE		0x1b
#define		BELL	 		0x07
;interne Definitionen
#define		CURSORLEFT		4
#define		CURSORRIGHT	3
#define		CURSORUP		1
#define		CURSORDOWN	2
#define		PAGEUP			5
#define		PAGEDOWN		6
#define		DELETE			0xe


#define		BLACK 		0x30
#define		RED			0x31
#define		GREEN		0x32
#define		BROWN		0x33
#define		BLUE			0x34
#define		PINK			0x35
#define		CYAN			0x36
#define		WHITE			0x37

#define		INOP		0
#define		IMOVW	1
#define		IMULS		2
#define		IMULSU	3
#define		IFMUL		4
#define		IFMULS	5
#define		IFMULSU	6
#define		ICPC		7
#define		ISBC		8
#define		IADD		9
#define		ICPSE		0xa
#define		ICP		0xb
#define		ISUB		0xc
#define		IADC		0xd
#define		IAND		0xe
#define		IEOR		0xf
#define		IOR		0X10
#define		IMOV		0X11
#define		ICPI		0X12
#define		ISBCI		0X13
#define		ISUBI		0X14
#define		IORI		0X15
#define		IANDI		0X16
#define		ILDDZ		0X17
#define		ILDDY		0X18
#define		ISTDZ		0X19
#define		ISTDY		0X1A
#define		ILDS		0X1B
#define		ILDZP		0X1C
#define		ILDZM		0X1D
#define		ILPMZ		0X1E
#define		ILPMZP	0X1F
#define		IELPMZ	0X20
#define		IELPMZP	0X21
#define		ILDYP		0X22
#define		ILDYM		0X23
#define		ILDX		0X24
#define		ILDXP		0X25
#define		ILDXM		0X26
#define		IPOP		0X27
#define		ISTS		0X28
#define		IPUSH		0X29
#define		ISTZP		0X2A
#define		ISTZM		0X2B
#define		ISTYP		0X2C
#define		ISTYM		0X2D
#define		ISTX		0X2E
#define		ISTXP		0X2F
#define		ISTXM		0X30
#define		ISEC		0X31
#define		IIJMP		0X32
#define		ISEZ		0X33
#define		ISEN		0X34
#define		ISEV		0X35
#define		ISES		0X36
#define		ISEH		0X37
#define		ISET		0X38
#define		ISEI		0X39
#define		ICLC		0X3A
#define		ICLZ		0X3B
#define		ICLN		0X3C
#define		ICLV		0X3D
#define		ICLS		0X3E
#define		ICLH		0X3F
#define		ICLT		0X40
#define		ICLI		0X41
#define		IRET		0X42
#define		IICALL		0X43
#define		IRETI		0X44
#define		ISLEEP	0X45
#define		IBREAK	0X46
#define		IWDR		0X47
#define		ILPM		0X48
#define		IELPM		0X49
#define		ISPM		0X4A
#define		ICOM		0X4B
#define		INEG		0X4C
#define		ISWAP		0X4D
#define		IINC		0X4E
#define		IASR		0X4F
#define		ILSR		0X50
#define		IROR		0X51
#define		IDEC		0X52
#define		IJMP		0X53
#define		ICALL		0X54
#define		IADIW		0X55
#define		ISBIW		0X56
#define		ICBI		0X57
#define		ICBIC		0X58
#define		ISBI		0X59
#define		ISBIS		0X5A
#define		IMUL		0X5B
#define		IIN		0X5C
#define		IOUT		0X5D
#define		IRJMP		0X5E
#define		IRCALL		0X5F
#define		ILDI		0X60
#define		IBRLO		0X61
#define		IBREQ		0X62
#define		IBRMI		0X63
#define		IBRVS		0X64
#define		IBRLT		0X65
#define		IBRHS		0X66
#define		IBRTS		0X67
#define		IBRIE		0X68
#define		IBRCC		0X69
#define		IBRNE		0X6A
#define		IBRPL		0X6B
#define		IBRVC		0X6C
#define		IBRGE		0X6D
#define		IBRHC		0X6E
#define		IBRTC		0X6F
#define		IBRID		0X70
#define		IBLD		0X71
#define		IBST		0X72
#define		ISBRC		0X73
#define		ISBRS		0X74
#define		IILLEGAL	0X75
#endif
