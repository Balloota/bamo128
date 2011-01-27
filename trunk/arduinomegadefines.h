
#define		INTERNALFLASHSTART		0x0000		// words
#define		INTERNALFLASHLENGTH		0x10000		// 64Kwords
#define		BOOTSECTIONSTART		0xf000		// word address
#define		BOOTSECTIONLENGTH		0x1000		// words

#define		INTERNALRAMSTART		0x200
#define		INTERNALRAMLENGTH		0x2200		// 8K
#define		EXTERNALRAMSTART		0x0000
#define		EXTERNALRAMLENGTH		0x0000
#define		BOARDRAMEND			0x2200
// monitor occupied 256 bytes before BOARDRAMEND

#define		INTERNALEEPROMSTART		0x0000
#define		INTERNALEEPROMLENGTH		0x1000		// 4K
#define		BAMOEEWE			EEPE		// eeprom read write
#define		BAMOEEMWE			EEMPE

#define		CPUFREQUENZ			16000000

#define		BAMOBAUDRATE			57600		// for arduino??   //115200

#define		LARGEBOOTSTART			0xF000		// words

#define		stepIntTimeConst		0x6

#if BAMOBAUDRATE == 57600
.equ		bdteiler,(CPUFREQUENZ/(16*BAMOBAUDRATE)-1)	; Baud-Divider
#else
.equ		bdteiler,(CPUFREQUENZ/(16*BAMOBAUDRATE))	; Baud-Divider
#endif

#define ENABLEEXTERNALRAM

#define	ENABLEMONITORUART	\
usartInit0:		lds	argVL, UCSR0A		/* sbis	_SFR_IO_ADDR(UCSRA), UDRE*/ $ \
			sbrs	argVL,UDRE0	$ \
			rjmp	usartInit0	 		/* Transmitter busy*/ $ \
			ldi 	argVL,0	$ \
			sts	UCSR0B,argVL			/* disable receiver, emitter*/ $ \
			sts	UCSR0A,argVL		$ \
			ldi	argVL,hi8(bdteiler)		/* Baudgenerator*/ $ \
			sts	UBRR0H,argVL 			/* Set divider*/ $ \
			ldi	argVL,lo8(bdteiler)		/* Baudgenerator*/ $ \
			sts	UBRR0L,argVL 			/* Set divide*/ $ \
			ldi	argVL, 0x06/*(1<<USBS0)|(3<<UCSZ00)*/	/* Set frame format: 8data, 1(2)stop bit */ $ \
			sts	UCSR0C ,argVL	$ \
			lds	argVL,DDRE	$ \
			andi	argVL,~PINE0	$ \
			sts	DDRE,argVL	$ \
			lds	argVL,PORTE	$ \
			ori	argVL,PINE0	$ \
			sts	PORTE,argVL	$ \
			ldi	argVL,(1<<RXEN0)|(1<<TXEN0)	/* Enable receiver and transmitter */ $ \
			sts	UCSR0B,argVL			/* out		_SFR_IO_ADDR(UCSRB), argVL*/ 

			
//		ldi	argVL,0x06
//		sts	UCSR0C,argVL

	
#define SEROUTMACRO	\
		push	argVL	$ \
serOut1:	lds	argVL,UCSR0A	$ \
		sbrs	argVL,UDRE0		/* Wait until transmit buffer empty */	$ \
		rjmp	serOut1				/* Transmitter busy*/	$ \
		pop	argVL $ \
		sts	UDR0,argVL			/* out	_SFR_IO_ADDR(UDR),argVL	 ; Send character (TXC0 <- 0?) */
		
#define	SERINMACRO lds	retVL,UDR0      ;in		retVL,UDR-0x20		; Get character from UART		

#define SERSTATMACRO 	lds	argVL,UCSR0A $ \
			sbrs	argVL,RXC0 $ \
;			sbis	_SFR_IO_ADDR(UCSRA),RXC0			; Test RXC-bit for waiting characters

#define	ENABLEMILLISECTIMER	sts TCCR1A,zeroReg	/* ms-timer1 ctc  counts up to OCR1A*/ $ \
			ldi	argVL, hi8(CPUFREQUENZ/1000) $ \
			sts	OCR1AH,argVL $ \
			ldi	argVL, lo8(CPUFREQUENZ/1000) $ \
			sts	OCR1AL,argVL

#define STARTMILLISECTIMER	\
		ldi	argVL,1+(1<<WGM12)			/* clock divider 1 (sysclock), ctc-mode*/ $ \
		sts	TCCR1B,argVL		/* system clock divided by 1*/	$ \
		lds	argVL,TIMSK1 $ \
		sbr	argVL,(1<<OCIE1A)		$ \
		sts 	TIMSK1,argVL
		
#define STOPMILLISECTIMER	\
		ldi	argVL,(1<<WGM12)	/* stop sys clock timer 1*/	$ \
		sts	TCCR1B,argVL $ \
		lds	argVL,TIMSK1	$ \
		cbr	argVL,(1<<TOIE1)	$ \
		sts	TIMSK1,argVL
		
#define STARTSTEPTIMER		\
		ldi	R27,stepIntTimeConst	/* = ZEITKONSTANTE bis Interrupt ausgelöst wird */ $ \
		sts	OCR2A,R27	/* Output Compare Register */ $ \
					/* wenn OCR == TCNT2 dann soll interupt kommen */ $ \
		lds	r27,TIMSK2			$ \
		sbr	r27,(1<<OCIE2A)			$ \
		sts	TIMSK2,r27 	/* -> Interupt  compare match timer 2 */ $ \
		lds	R27,USERSREG			$ \
		out	_SFR_IO_ADDR(SREG),R27	/* RAMPZ und SREG laden */ $ \
		ldi	R27,0b00000001			$ \
/* Clear Timer on Compare (Vergleich mit BAMOOCR2) - Bit 4 von rechts, Systemtakt - Bit 1 von rechts */ $ \
		sts	TCCR2B,R27 			/* Timer/Counter Control Register 2 */

#define DISABLESTEPINTERRUPTS	\
		lds	r27,TIMSK2	$ \
		cbr	r27,(1<<OCIE2A)	$ \
		sts	TIMSK2,r27	; -> Interrupt bei Compare timer2 ausgeschaltet

#define STOPSTEPTIMER	\
		ldi	R27,0b00001000		/* timer ausschalten */ $ \
		sts	TCCR2B,R27			$ \
		clr	R27			/* Time/CouNTer2 auf 0 setzen */ $ \
		sts	TCNT2,R27		$ \
		ldi	R27,(1<<OCF2A)		/* Output Compare Flag 2 zuruecksetzen */ $ \
		sts	TIFR2,R27		/* "OCF2 is cleaRED by writing a logic one to the flag." */
