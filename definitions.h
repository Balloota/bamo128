/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/

/*	still a simulator for atmaga128
	inspired by  Z80-dis from Petr Kulhavy http://wwwhomes.uni-bielefeld.de/achim/z80-asm.html

	Version 0.1		-> 	06.06.06
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *************************************************************************/
#ifndef	__definitions__
#define	__definitions__

#define 		CASE	break;case
#define			sshort	signed short
#define			D2	(((instr>>4)&0x03)+24)						//value
#define			D3U	(16+((instr>>4)&0x7))
#define			D4	((instr>>4)&0xf)
#define			D4U	(D4+16)	// upper half of regs
#define			D5	((instr>>4)&0x1f)
#define			R3U	(16+(instr&7))
#define			R4	(instr&0xf)
#define			R4U	(R4+16)		// upper half of regs
#define			R5	((R4)|(instr&0x200)>>5)
#define			K5	((instr&7)|((instr>>7)&0x18)|((instr>>8)&0x20))
#define			K6	(((((sshort)((instr&0x0f)|((instr>>2)&0x0030)))<<10)>>10)&0x3f)
#define			K7	(((short)((((instr>>3)&0x7f)<<9))>>9)&0xffff)
#define			K8	((instr&0xf)|((instr>>4)&0xf0))
#define			K12	((((sshort)((instr&0xfff)<<4))>>4)&0xffff)
#define			COND	((instr&0x7)|((instr&0x600)>>4))
#define			P5	(((instr>>3)&0x1f)+0x20)
#define			P6	((instr&0xf)|((instr&0x600)>>7)+0x20)
#define			MBIT	(instr&7)

#define			BITSET(b,nn)	(nn|=((1<<(b))))				// expr
#define			BITCLEAR(b,nn) (nn&=((~(1<<(b)))))		// expr
#define	CSET			(*sReg|=0x01)				// expr
#define	CCLEAR		(*sReg&=0xFE)
#define	ZSET			(*sReg|=0x02)
#define	ZCLEAR		(*sReg&=0xFD)
#define	NSET			(*sReg|=0x04)
#define	NCLEAR		(*sReg&=0xFB)
#define	VSET			(*sReg|=0x08)
#define	VCLEAR		(*sReg&=0xF7)
#define	SSET			(*sReg|=0x10)
#define	SCLEAR		(*sReg&=0xEF)
#define	HSET			(*sReg|=0x20)
#define	HCLEAR		(*sReg&=0xDF)
#define	TSET			(*sReg|=0x40)
#define	TCLEAR		(*sReg&=0xBF)
#define	ISET			(*sReg|=0x80)
#define	ICLEAR		(*sReg&=0x7F)


#define	BIT(b,nn)	(((nn)>>(b))&0x01)			// value
#define	CBIT		(*sReg&0x01)				// value
#define	ZBIT		((*sReg>>1)&1)
#define	NBIT		((*sReg>>2)&1)
#define	VBIT		((*sReg>>3)&1)
#define	SBIT		((*sReg>>4)&1)
#define	HBIT		((*sReg>>5)&1)
#define	TBIT		((*sReg>>6)&1)
#define	IBIT		((*sReg>>7)&1)


#define	CCHANGE(v)	(((v))?CSET:CCLEAR)			//expr/value
#define	ZCHANGE(v)	(((v))?ZSET:ZCLEAR)
#define	NCHANGE(v)	(((v))?NSET:NCLEAR)
#define	VCHANGE(v)	(((v))?VSET:VCLEAR)
#define	SCHANGE(v)	(((v))?SSET:SCLEAR)
#define	HCHANGE(v)	(((v))?HSET:HCLEAR)
#define	TCHANGE(v)	(((v))?TSET:TCLEAR)
#define	ICHANGE(v)	(((v))?ISET:ICLEAR)

#define	MUCA			\
	ZCHANGE((result==0));\
	CCHANGE(result&0x8000);\
	if (more) result<<=1;\
	sRam[0]=(uchar)result&0xFF;\
	sRam[1]=(uchar)(result<<8)&0xFF;\
	break;\
	case

#define	SUBFLAGSCHANGE(r,rd,rr)	\
	CCHANGE((!BIT(7,r)&&BIT(7,rr))||(BIT(7,rr)&&BIT(7,r))||(BIT(7,r)&&!BIT(7,rd)));\
	HCHANGE((!BIT(3,r)&&BIT(3,rr))||(BIT(3,rr)&&BIT(3,r))||(BIT(3,r)&&!BIT(3,rd)));\
	ZCHANGE(((r&0xff)==0));\
	VCHANGE((BIT(7,rd)&&!BIT(7,rr)&&!BIT(7,r))||(BIT(7,rr)&&BIT(7,r)));\
	NCHANGE(BIT(7,r));\
	SCHANGE((NBIT^VBIT)&0x01)

#define	ADDFLAGSCHANGE(r,rd,rr)	\
	CCHANGE((BIT(7,rd)&&BIT(7,rr))||(BIT(7,rr)&&(!BIT(7,r)))||((!BIT(7,r))&&BIT(7,rd)));\
	HCHANGE((BIT(3,rd)&&BIT(3,rr))||(BIT(3,rr)&&(!BIT(3,r)))||((!BIT(3,r))&&BIT(3,rd)));\
	ZCHANGE((r&0xff)==0);\
	VCHANGE((BIT(7,rd)&&BIT(7,rr)&&(!BIT(7,r)))||((!BIT(7,rd))&&(!BIT(7,rr))&&BIT(7,r)));\
	NCHANGE(BIT(7,r));\
	SCHANGE((NBIT^VBIT)&0x01)

#define	LOGICFLAGSCHANGE(r)	\
	ZCHANGE((r&0xff)==0);\
	NCHANGE(BIT(7,r));\
	VCLEAR;\
	SCHANGE((NBIT^VBIT)&0x01)


;

enum	 instrCode {		NOP=0, MOVW, MULS, MULSU, FMUL,  FMULS, FMULSU, CPC,
						SBC=8, ADD, CPSE, CP, SUB , ADC, AND , EOR,
						OR=16, MOV, CPI, SBCI, SUBI, ORI, ANDI, LDDZ,
						LDDY=24,STDZ, STDY, LDS, LDZP, LDZM, LPMZ, LPMZP,
						ELPMZ=32, ELPMZP, LDYP, LDYM, LDX, LDXP, LDXM, POP,
						STS=40, PUSH, STZP, STZM, STYP, STYM, STX, STXP,
						STXM=48, SEC, IJMP, SEZ, SEN, SEV, SES, SEH,
						SET=56, SEI, CLC, CLZ, CLN, CLV, CLS, CLH,
						CLT=64, CLI, RET, ICALL, RETI, SLEEP, BREAK, WDR,
						LPM=72, ELPM,SPM, COM, NEG, SWAP, INC, ASR,
						LSR=80,	ROR, DEC, JMP, CALL, ADIW, SBIW, CBI,
						CBIC=88,  SBI, SBIS, MUL, IN, OUT, RJMP, RCALL,
						LDI=96, BRLO, BREQ, BRMI, BRVS, BRLT, BRHS, BRTS,
						BRIE=104, BRCC, BRNE, BRPL, BRVC, BRGE, BRHC, BRTC,
						BRID=112, BLD, BST, SBRC, SBRS, ILLEGAL						};
#endif

