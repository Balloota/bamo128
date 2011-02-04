
#define		ATMEGA128

#define		INTERNALFLASHSTART		0x0000		// words
#define		INTERNALFLASHLENGTH		0x10000
#define		BOOTSECTIONSTART		0xf000		// word address
#define		BOOTSECTIONLENGTH		0x1000		// words
#define		LARGEBOOTSTART			0xF000		// monitor starts here

#define		INTERNALRAMSTART		0x100
#define		INTERNALRAMLENGTH		0x1100
#define		EXTERNALRAMSTART		0x1100
#define		EXTERNALRAMLENGTH		0x7000
#define		BOARDRAMEND			0x8000
// monitor occupied 256 bytes before BOARDRAMEND

#define		INTERNALEEPROMSTART		0x0000
#define		INTERNALEEPROMLENGTH		0x1000
#define		BAMOEEWE			EEWE
#define		BAMOEEMWE			EEMWE

#define		CPUFREQUENZ			14745000

#define		BAMOBAUDRATE			115200

#define		stepIntTimeConst		0x0a


// correct it for avr-as
.macro input
  .if @1 < 0x40
	in	@0, @1
  .else
  	lds	@0, @1
  .endif
.endm

.macro output
  .if @0 < 0x40
	out	@0, @1
  .else
  	sts	@0, @1
  .endif
.endm

#define ENABLEEXTERNALRAM	/* only C comments !! $ is newline!!! */\
		      ldi	argVL,(1<<SRE)| (1<<IVCE) $ \
		      out	_SFR_IO_ADDR(MCUCR), argVL

#define	ENABLEMILLISECTIMER	out	_SFR_IO_ADDR(TCCR1A),zeroReg	/* ms-timer1 ctc  counts up to OCR1A*/$ \
			ldi	argVL, hi8(CPUFREQUENZ/1000) $ \
			out	_SFR_IO_ADDR(OCR1AH),argVL $ \
			ldi	argVL, lo8(CPUFREQUENZ/1000) $ \
			out	_SFR_IO_ADDR(OCR1AL),argVL

#define	ENABLEMONITORUART	\
usartInit0:		lds	argVL, UCSR0A		/* sbis	_SFR_IO_ADDR(UCSRA), UDRE*/ $ \
			sbrs	argVL,UDRE0	$ \
			rjmp	usartInit0	 		/* Transmitter busy*/ $ \
			ldi	argVL,hi8(bdteiler)		/* Baudgenerator*/ $ \
			sts	UBRR0H,argVL 			/* Set divider*/ $ \
			ldi	argVL,lo8(bdteiler)		/* Baudgenerator*/ $ \
			sts	UBRR0L,argVL 			/* Set divide*/ $ \
			ldi	argVL,(1<<RXEN0)|(1<<TXEN0)	/* Enable receiver and transmitter */ $ \
			sts	UCSR0B,argVL			/* out		_SFR_IO_ADDR(UCSRB), argVL*/ $ \
			ldi	argVL, (1<<USBS0)|(3<<UCSZ0)	/* Set frame format: 8data, 2stop bit */ $ \
			sts	UCSR0C ,argVL
			
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

#define STARTMILLISECTIMER	\
		ldi	argVL,1+(1<<WGM12)		/*	clock divider 1 (sysclock), ctc-mode*/ $ \
	out	_SFR_IO_ADDR(TCCR1B),argVL		/* system clock divided by 1*/	$ \
		in	argVL,_SFR_IO_ADDR(TIMSK) $ \
		sbr	argVL,(1<<OCIE1A)	$ \
		out	_SFR_IO_ADDR(TIMSK),argVL
		
#define STOPMILLISECTIMER	\
		ldi	argVL,(1<<WGM12)	/* stop sys clock timer 1	*/$ \
		out	_SFR_IO_ADDR(TCCR1B),argVL $ \
		lds	argVL,TIMSK	$ \
		cbr	argVL,(1<<TOIE1)	$ \
		sts	TIMSK,argVL
		
#define STARTSTEPTIMER		\
		ldi	R27,stepIntTimeConst	/* = ZEITKONSTANTE bis Interrupt ausgelöst wird*/ $ \
		sts	OCR2,R27	/* Output Compare Register*/ $ \
						/* wenn OCR == TCNT2 dann soll interupt kommen*/ $ \
		lds	r27,TIMSK			$ \
		sbr	r27,(1<<OCIE2)			$ \
		sts	TIMSK,r27 		/* -> Interupt  compare match timer 2*/$ \
		lds	R27,USERSREG			$ \
		out	_SFR_IO_ADDR(SREG),R27	/*RAMPZ und SREG laden*/ $ \
		ldi	R27,0b00001001			$ \
/* Clear Timer on Compare (Vergleich mit BAMOOCR2) - Bit 4 von rechts, Systemtakt - Bit 1 von rechts*/ $ \
		sts	TCCR2,R27 			/* Timer/Counter Control Register 2*/
#define DISABLESTEPINTERRUPTS	\
		lds	r27,TIMSK	$ \
		cbr	r27,(1<<OCIE2)	$ \
		sts	TIMSK,r27	; -> Interrupt bei Compare timer2 ausgeschaltet
#define STOPSTEPTIMER	\
		ldi	R27,0b00001000		/* timer ausschalten*/ $ \
		sts	TCCR2,R27			$ \
		clr	R27			/* Time/CouNTer2 auf 0 setzen*/ $ \
		sts	TCNT2,R27		$ \
		ldi	R27,(1<<OCF2)		/* Output Compare Flag 2 zuruecksetzen*/ $ \
		sts	TIFR,R27		; "OCF2 is cleaRED by writing a logic one to the flag."
