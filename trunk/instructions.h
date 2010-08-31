/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/

 *************************************************************************/
//imask, 	instrbits,  			obits, 					oname, 		comment
{0XFFFF,0X0000,"0000	0000	0000	0000",		"NOP      ",},				//00
{0XFF00,0X0100,"0000	0001	DDDD	RRRR",	"MOVW    RD,RR"},		//01
{0XFF00,0X0200,"0000	0002	DDDD	RRRR",	"MULS    RD,RR"},		//02
{0XFF88,0X0300,"0000	0003	0DDD	0RRR",	"MULSU   RD,RR"},		//03
{0XFF88,0X0308,"0000	0002	0DDD	0RRR",	"FMUL    RD,RR"},		//04
{0XFF88,0X0380,"0000	0002	1DDD	0RRR",	"FMULS  RD,RR"},		//05
{0XFF88,0X0388,"0000	0002	1DDD	1RRR",	"FMULSU RD,RR"},		//06
{0XFC00,0X0400,"0000	01RD	DDDD	RRRR",	"CPC     RD,RR"},		//07
{0XFC00,0X0800,"0000	01RD	DDDD	RRRR",	"SBC     RD,RR"},		//08
//lsL -> add
{0XFC00,0X0C00,"0000	01RD	DDDD	RRRR",	"ADD     RD,RR"},		//09
{0XFC00,0X1000,"0001	00RD	DDDD	RRRR",	"CPSE    RD,RR"},		//10
{0XFC00,0X1400,"0001	01RD	DDDD	RRRR",	"CP      RD,RR"},			//11
{0XFC00,0X1800,"0001	10RD	DDDD	RRRR",	"SUB     RD,RR"},		//12
// ROL -> ADC RD.RR
{0XFC00,0X1C00,"0001	11RD	DDDD	RRRR",	"ADC     RD,RR"},		//13
//TST -> AND
{0XFC00,0X2000,"0010	20RD	DDDD	RRRR",	"AND     RD,RR"},		//14
// CLR -< EOR
{0XFC00,0X2400,"0010	01RD	DDDD	RRRR",	"EOR     RD,RRR"},		//15
{0XFC00,0X2800,"0010	10RD	DDDD	RRRR",	"OR      RD,RR"},		//16
{0XFC00,0X2C00,"0010	11RD	DDDD	RRRR",	"MOV     RD,RR"},		//17
{0XF000,0X3000,"0011	KKKK	DDDD	KKKK",	"CPI     RD,K"},			//18
{0XF000,0X4000,"0100	KKKK	DDDD	KKKK",	"SBCI    RD,K"},			//19
{0XF000,0X5000,"0101	KKKK	DDDD	KKKK",	"SUBI    RD,K"},			//20
{0XF000,0X6000,"0110	KKKK	DDDD	KKKK",	"ORI     RD,K"},			//21
//SBR ->ORI
{0XF000,0X7000,"0111	KKKK	DDDD	KKKK",	"ANDI    RD,K"},			//22
// CBR-> ANDI
// LD RD,Z -> LD RD,Z+Q
{0XFE0F,0X8000,"10Q0	QQ0D	DDDD	0QQQ",	"LDD     RD,Z+K"},		//23
// LD RD,Y -> LD RD,Y+Q
{0XFE0F,0X8008,"10Q0	QQ0D	DDDD	0QQQ",	"LDD     RD,Y+K"},		//24
// ST Z,RR	-> ST Z+Q,RR
{0XFE0F,0X8200,"10Q0	QQ1R	RRRR0QQQ",	"STD     Z+K,RR"},		//25
//ST Y,RR	-> ST Y+Q,RR
{0XFE0F,0X8208,"10Q0	QQ1R	RRRR8QQQ",	"STD     Y+K,RR"},		//26
{0XFE0F,0X9000,"1001	000D	DDDD	0000",		"LDS     RD,0x__"},		//27
{0XFE0F,0X9001,"1001	000D	DDDD	0001",		"LD      RD,Z+"},			//28
{0XFE0F,0X9002,"1001	000D	DDDD	0010",		"LD      RD,-Z"},			//29 
{0XFE0F,0X9004,"1001	000D	DDDD	0100",		"LPM     RD,Z"},			//30
{0XFE0F,0X9005,"1001	000D	DDDD	0101",		"LPM     RD,Z+"},		//31
{0XFE0F,0X9006,"1001	000D	DDDD	0110",		"ELPM    RD,Z"},			//32
{0XFE0F,0X9007,"1001	000D	DDDD	0111",		"ELPM    RD,Z+"},		//33
{0XFE0F,0X9009,"1001	000D	DDDD	1001",		"LD      RD,Y+"},			//34
{0XFE0F,0X900A,"1001	000D	DDDD	1010",		"LD      RD,-Y"},			//35
{0XFE0F,0X900C,"1001	000D	DDDD	1100",		"LD      RD,X"},			//36
{0XFE0F,0X900D,"1001	000D	DDDD	1101",		"LD      RD,X+"},			//37
{0XFE0F,0X900E,"1001	000D	DDDD	1110",		"LD      RD,-X"},			//38
{0XFE0F,0X900F,"1001	000D	DDDD	1111",		"POP     RR"},			//39
{0XFE0F,0X9200,"1001	001R	RRRR0000",		"STS     K,RR "},			//40
{0XFE0F,0X920F,"1001	001R	RRRR1111",		"PUSH    RR"},			//41
{0XFE0F,0X9201,"1001	001R	RRRR0001",		"ST      Z+,RR"},			//42
{0XFE0F,0X9202,"1001	001R	RRRR0010",		"ST      -Z,RR"},			//43
{0XFE0F,0X9209,"1001	001R	RRRR1001",		"ST      Y+,RR"},			//44
{0XFE0F,0X920A,"1001	001R	RRRR1010",		"ST      -Y,RR"},			//45
{0XFE0F,0X920C,"1001	001R	RRRR1100",		"ST      X,RR"},			//46
{0XFE0F,0X920D,"1001	001R	RRRR1101",		"ST      X+,RR"},			//47
{0XFE0F,0X920E,"1001	001R	RRRR1110",		"ST      -X,RR"},			//48
//BSET -> set bit in sreg
//BCLR
{0XFFFF,0X9408,"1001		0100	0000	1000",	"SEC     "},				//49
{0XFFFF,0X9409,"1001		0100	0000	1001",	"IJMP     "},				//50
{0XFFFF,0X9418,"1001		0100	0001	1000",	"SEZ     "},				//51
{0XFFFF,0X9428,"1001		0100	0010	1000",	"SEN     "},				//52
{0XFFFF,0X9438,"1001		0100	0011	1000",	"SEV     "},				//53
{0XFFFF,0X9448,"1001		0100	0100	1000",	"SES     "},				//54
{0XFFFF,0X9458,"1001		0100	0101	1000",	"SEH     "},				//55
{0XFFFF,0X9468,"1001		0100	0110	1000",	"SET     "},				//56
{0XFFFF,0X9478,"1001		0100	0111	1000",	"SEI     "},				//57
{0XFFFF,0X9488,"1001		0100	1000	1000",	"CLC     "},				//58
{0XFFFF,0X9498,"1001		0100	1001	1000",	"CLZ     "},				//59
{0XFFFF,0X94A8,"1001	0100	1010	1000",	"CLN     "},				//60
{0XFFFF,0X94B8,"1001	0100	1011	1000",	"CLV     "},				//61
{0XFFFF,0X94C8,"1001	0100	1100	1000",	"CLS     "},				//62
{0XFFFF,0X94D8,"1001	0100	1101	1000",	"CLH     "},				//63
{0XFFFF,0X94E8,"1001	0100	1110	1000",	"CLT     "},				//64
{0XFFFF,0X94F8,"1001		0100	1111	1000",	"CLI     "},				//65
{0XFFFF,0X9508,"1001	0101	1000	1000",	"RET      "},				//66
{0XFFFF,0X9509,"1001	0101	0000	1001",	"ICALL   "},				//67
{0XFFFF,0X9518,"1001		0101	0001	1000",	"RETI      "},			//68
{0XFFFF,0X9588,"1001		0101	1000	1000",	"SLEEP      "},			//69
{0XFFFF,0X9598,"1001		0101	1001	1000",	"BREAK      "},			//70
{0XFFFF,0X95A8,"1001	0101	1010	1000",	"WDR     "},				//71
{0XFFFF,0X95C8,"1001	0101	1100	1000",	"LPM     "},				//72
{0XFFFF,0X95D8,"1001	0101	1101	1000",	"ELPM     "},			//73
{0XFFFF,0X95E8,"1001	0101	1110	1000",	"SPM      "},				//74
{0XFE0F,0X9400,"1001	010D	DDDD	0000",	"COM     RD"},			//75
{0XFE0F,0X9401,"1001	010D	DDDD	0001",	"NEG     RD"},			//76
{0XFE0F,0X9402,"1001	010D	DDDD	0010",	"SWAP     RD"},		//77
{0XFE0F,0X9403,"1001	010D	DDDD	0011",	"INC     RD"},			//78
{0XFE0F,0X9405,"1001	010D	DDDD	0101",	"ASR     RD"},			//79
{0XFE0F,0X9406,"1001	010D	DDDD	0110",	"LSR     RD"},			//80
{0XFE0F,0X9407,"1001	010D	DDDD	0111",	"ROR     RD"},			//81
{0XFE0F,0X940A,"1001	010D	DDDD	1010",	"DEC     RD"},			//82
{0XFE0E,0X940C,"1001	0100	0000	1100",	"JMP     K"},			//83
{0XFE0F,0X940E,"1001	0100	0000	1110",	"CALL    K"},			//84
{0XFF00,0X9600,"1001	0110	KKDD	KKKK",	"ADIW    RD,K"},		//85
{0XFF00,0X9700,"1001	0111	KKDD	KKKK",	"SBIW    RD,K"},		//86
{0XFF00,0X9800,"1001	1000	AAAA	ABBB",	"CBI     P,B"},			//87
{0XFF00,0X9900,"1001	1001	AAAA	ABBB",	"CBIC    P,B"},			//88
{0XFF00,0X9A00,"1001	1010	AAAA	ABBB",	"SBI      P,B"},			//89
{0XFF00,0X9B00,"1001	1011	AAAA	ABBB",	"SBIS    P,B"},			//90
{0XFC00,0X9C00,"1001	11DR	DDDD	RRRR",	"MUL     RD,RR"},		//91
{0XF800,0XB000,"1011	0AAD	DDDD	AAAA",	"IN      RD,,P"},			//92
{0XF800,0XB800,"1011	1AAD	DDDD	AAAA",	"OUT     P,RR"},		//93
{0XF000,0XC000,"1100	KKKK	KKKK	KKKK",	"RJMP    K"},			//94
{0XF000,0XD000,"1101	KKKK	KKKK	KKKK",	"RCALL   K"},			//95
{0XF000,0XE000,"1110	KKKK	DDDD	KKKK",	"LDI     RD,K"},			//96
// brcs->BRLO
{0XFC07,0XF000,"1111	00KK	KKKK	K000",	"BRLO    K"},			//97
{0XFC07,0XF001,"1111	00KK	KKKK	K001",	"BREQ    K"},			//98
{0XFC07,0XF002,"1111	00KK	KKKK	K010",	"BRMI    K"},			//99
{0XFC07,0XF003,"1111	00KK	KKKK	K011",	"BRVS    K"},			//100
{0XFC07,0XF004,"1111	00KK	KKKK	K100",	"BRLT    K"},			//101
{0XFC07,0XF005,"1111	00KK	KKKK	K101",	"BRHS    K"},			//102
{0XFC07,0XF006,"1111	00KK	KKKK	K110",	"BRTS    K"},			//103
{0XFC07,0XF007,"1111	00KK	KKKK	K111",	"BRIE    K"},			//104
//BRBS |^
{0XFC07,0XF400,"1111	01KK	KKKK	K000",	"BRCC    K"},			//105
//BRSH -> BRCC
{0XFC07,0XF401,"1111		01KK	KKKK	K001",	"BRNE    K"},			//106
{0XFC07,0XF402,"1111		01KK	KKKK	K010",	"BRPL    K"},			//107
{0XFC07,0XF403,"1111		01KK	KKKK	K011",	"BRVC    K"},			//108
{0XFC07,0XF404,"1111		01KK	KKKK	K100",	"BRGE    K"},			//109
{0XFC07,0XF405,"1111	01KK	KKKK	K101",	"BRHC    K"},			//110
{0XFC07,0XF406,"1111		01KK	KKKK	K110",	"BRTC    K"},			//111
{0XFC07,0XF407,"1111		01KK	KKKK	K111",	"BRID    K"},			//112
// BRBC |^
{0XFE08,0XF800,"1111		100D	DDDD	0BBB","BLD     RD,B"},			//113
{0XFE08,0XFA00,"1111	101D	DDDD	0BBB","BST     RR,B"},			//114
{0XFE08,0XFC00,"1111	110D	DDDD	0BBB","SBRC    RR,B"},		//115
{0XFE08,0XFE00,"1111	111D	DDDD	0BBB","SBRS    RR,B"},			//116
{0X0000,0X0000,"0000	0000	0000	0000","ILLEGAL "}				//117
