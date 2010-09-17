// IV-Vector-Table
// atmega1280
;################################ iv-tab ##########################################
RESET:			
/*$0000*/	  jmp    BOOTSTART
/*0x0002*/        jmp 	EXTINT0        ; IRQ0 Handler
/*0x0004*/        jmp 	EXTINT1        ; IRQ1 Handler
/*0x0006*/        jmp 	EXTINT2        ; IRQ2 Handler
/*0x0008*/        jmp 	EXTINT3        ; IRQ3 Handler
/*0x000A*/        jmp 	EXTINT4        ; IRQ4 Handler
/*0x000C*/        jmp 	EXTINT5        ; IRQ5 Handler
/*0x000E*/        jmp 	EXTINT6        ; IRQ6 Handler
/*0x0010*/        jmp	EXTINT7        ; IRQ7 Handler
/*0x0012*/        jmp	EXTPCINT0      ; PCINT0 Handler
/*0x0014*/        jmp	EXTPCINT1      ; PCINT1 Handler
/*0x0016*/        jmp	EXTPCINT2      ; PCINT2 Handler
/*0X0018*/        jmp	WDT         ; Watchdog Timeout Handler
/*0x001A*/        jmp	saveCPU		; monitor step mode!! TIM2_COMPA  ; Timer2 CompareA Handler
/*0x001C*/        jmp	TIM2_COMPB  ; Timer2 CompareB Handler
/*0x001E*/        jmp	TIM2_OVF    ; Timer2 Overflow Handler
/*0x0020*/        jmp	TIM1_CAPT   ; Timer1 Capture Handler
/*0x0022*/        jmp	mySysClock		;TIM1_COMPA  ; Timer1 CompareA Handler
/*0x0024*/        jmp	TIM1_COMPB  ; Timer1 CompareB Handler
/*0x0026*/        jmp	TIM1_COMPC  ; Timer1 CompareC Handler
/*0x0028*/        jmp	TIM1_OVF    ; Timer1 Overflow Handler
/*0x002A*/        jmp	TIM0_COMPA  ; Timer0 CompareA Handler
/*0x002C*/        jmp	TIM0_COMPB  ; Timer0 CompareB Handler
/*0x002E*/        jmp	TIM0_OVF    ; Timer0 Overflow Handler
/*0x0030*/        jmp	SPI_STC     ; SPI Transfer Complete Handler
/*0x0032*/        jmp	USART0_RXC  ; USART0 RX Complete Handler
/*0x0034*/        jmp	USART0_UDRE ; USART0,UDR Empty Handler
/*0x0036*/        jmp	USART0_TXC  ; USART0 TX Complete Handler
/*0x0038*/        jmp	ANA_COMP    ; Analog Comparator Handler
/*0x003A*/        jmp	ADCONV      ; ADC Conversion Complete Handler
/*0x003C*/        jmp	EE_RDY      ; EEPROM Ready Handler
/*0x003E*/        jmp	TIM3_CAPT   ; Timer3 Capture Handler
/*0x0040*/        jmp	TIM3_COMPA  ; Timer3 CompareA Handler
/*0x0042*/        jmp	TIM3_COMPB  ; Timer3 CompareB Handler
/*0x0044*/        jmp	TIM3_COMPC  ; Timer3 CompareC Handler
/*0x0046*/        jmp     TIM3_OVF          ; Timer3 Overflow Handler
/*0x0048*/        jmp     USART1_RXC        ; USART1 RX Complete Handler
/*0x004A*/        jmp     USART1_UDRE       ; USART1,UDR Empty Handler
/*0x004C*/        jmp     USART1_TXC        ; USART1 TX Complete Handler
/*0x004E*/        jmp     TWI               ; 2-wire Serial Handler
/*0x0050*/        jmp     SPM_RDY           ; SPM Ready Handler
/*0x0052*/        jmp     TIM4_CAPT         ; Timer4 Capture Handler
/*0x0054*/        jmp     TIM4_COMPA        ; Timer4 CompareA Handler
/*0x0056*/        jmp     TIM4_COMPB        ; Timer4 CompareB Handler
/*0x0058*/        jmp     TIM4_COMPC        ; Timer4 CompareC Handler
/*0x005A*/        jmp     TIM4_OVF          ; Timer4 Overflow Handler
/*0x005C*/        jmp     TIM5_CAPT         ; Timer5 Capture Handler
/*0x005E*/        jmp     TIM5_COMPA        ; Timer5 CompareA Handler
/*0x0060*/        jmp     TIM5_COMPB        ; Timer5 CompareB Handler
/*0x0062*/        jmp     TIM5_COMPC        ; Timer5 CompareC Handler
/*0x0064*/        jmp     TIM5_OVF          ; Timer5 Overflow Handler
/*0x0066*/        jmp     USART2_RXC        ; USART2 RX Complete Handler
/*0x0068*/        jmp     USART2_UDRE       ; USART2,UDR Empty Handler
/*0x006A*/        jmp     USART2_TXC        ; USART2 TX Complete Handler
/*0x006C*/        jmp     USART3_RXC        ; USART3 RX Complete Handler
/*0x006E*/        jmp     USART3_UDRE       ; USART3,UDR Empty Handler
/*0x0070*/        jmp     USART3_TXC        ; USART3 TX Complete Handler
EXTINT0:
EXTINT1:
EXTINT2:
EXTINT3:
EXTINT4:
EXTINT5:
EXTINT6:
EXTINT7:
EXTPCINT0:
EXTPCINT1:
EXTPCINT2:
WDT:
TIM2_COMPA:
TIM2_COMPB:
TIM2_OVF:
TIM1_CAPT:
TIM1_COMPA:
TIM1_COMPB:
TIM1_COMPC:
TIM1_OVF:
TIM0_COMPA:
TIM0_COMPB:
TIM0_OVF:
SPI_STC:
USART0_RXC:
USART0_UDRE:
USART0_TXC:
ANA_COMP:
ADCONV:
EE_RDY:
TIM3_CAPT:
TIM3_COMPA:
TIM3_COMPB:
TIM3_COMPC:
TIM3_OVF:
USART1_RXC:
USART1_UDRE:
USART1_TXC:
TWI:
SPM_RDY:
TIM4_CAPT:
TIM4_COMPA:
TIM4_COMPB:
TIM4_COMPC:
TIM4_OVF:
TIM5_CAPT:
TIM5_COMPA:
TIM5_COMPB:
TIM5_COMPC:
TIM5_OVF:
USART2_RXC:
USART2_UDRE:
USART2_TXC:
USART3_RXC:
USART3_UDRE:
USART3_TXC:
			rjmp RESET