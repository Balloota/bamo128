// IV-Vector-Table
;################################ iv-tab ##########################################
RESET:			; charonII and arduinoMega with bamo128 starts by 0xf000 on reset
; External Pin, Power-on Reset, Brown-out Reset,
; Watchdog Reset, and JTAG AVR Reset
/*$0000*/	jmp    BOOTSTART    		; Reset Handler
/*$0002*/ 	jmp    EXT_INT0			; IRQ0 Handler
/*$0004*/       jmp    EXT_INT1  		; IRQ1 Handler
/*$0006*/       jmp    EXT_INT2  		; IRQ2 Handler
/*$0008*/       jmp    EXT_INT3  		; IRQ3 Handler
/*$000A*/       jmp    EXT_INT4  		; IRQ4 Handler
/*$000C*/       jmp    EXT_INT5  		; IRQ5 Handler
/*$000E*/       jmp    EXT_INT6  		; IRQ6 Handler
/*$0010*/       jmp    EXT_INT7  		; IRQ7 Handler
/*$0012*/       jmp    saveCPU			;TIM2_COMP -> used for step and break; Timer2 Compare 
/*$0014*/       jmp    TIM2_OVF  		; Timer2 Overflow Handler
/*$0016*/       jmp    TIM1_CAPT 		; Timer1 Capture Handler
/*$0018*/       jmp    mySysClock		;TIM1_COMPA		; Timer1 CompareA Handler
/*$001A*/       jmp    TIM1_COMPB		; Timer1 CompareB Handler
/*$001C*/       jmp    TIM1_OVF  		; Timer1 Overflow Handler
/*$001E*/       jmp    TIM0_COMP 		; Timer0 Compare Handler
/*$0020*/       jmp    TIM0_OVF  		; Timer0 Overflow Handler
/*$0022*/       jmp    SPI_STC   		; SPI Transfer Complete Handler
/*$0024*/       jmp    USART0_RXC		; USART0 RX Complete Handler
/*$0026*/       jmp    USART0_DRE		; USART0,UDR Empty Handler
/*$0028*/       jmp    USART0_TXC		; USART0 TX Complete Handler
/*$002A*/       jmp    ADCONV       		; ADC Conversion Complete Handler
/*$002C*/       jmp    EE_RDY    		; EEPROM Ready Handler
/*$002E*/       jmp    ANA_COMP  		; Analog Comparator Handler
/*$0030*/       jmp    TIM1_COMPC		; Timer1 CompareC Handler
/*$0032*/       jmp    TIM3_CAPT 		; Timer3 Capture Handler
/*$0034*/       jmp    TIM3_COMPA		; Timer3 CompareA Handler
/*$0036*/       jmp    TIM3_COMPB		; Timer3 CompareB Handler
/*$0038*/       jmp    TIM3_COMPC		; Timer3 CompareC Handler
/*$003A*/       jmp    TIM3_OVF  		; Timer3 Overflow Handler
/*$003C*/       jmp    USART1_RXC		; USART1 RX Complete Handler
/*$003E*/       jmp    USART1_DRE		; USART1,UDR Empty Handler
/*$0040*/       jmp    USART1_TXC		; USART1 TX Complete Handler
/*$0042*/       jmp    TWI       		; Two-wire Serial Interface Interrupt Handler
/*$0044*/       jmp    SPM_RDY   		; SPM Ready Handler
			
EXT_INT0:		; IRQ0 Handler
EXT_INT1:  		; IRQ1 Handler
EXT_INT2:  		; IRQ2 Handler
EXT_INT3:  		; IRQ3 Handler
EXT_INT4:  		; IRQ4 Handler
EXT_INT5:  		; IRQ5 Handler
EXT_INT6:  		; IRQ6 Handler
EXT_INT7:  		; IRQ7 Handler
TIM2_COMP: 		; Timer2 Compare Handler
TIM2_OVF:  		; Timer2 Overflow Handler
TIM1_CAPT: 		; Timer1 Capture Handler
TIM1_COMPA:		; Timer1 CompareA Handler
TIM1_COMPB:		; Timer1 CompareB Handler
TIM1_OVF:  		; Timer1 Overflow Handler
TIM0_COMP:	 	; Timer0 Compare Handler
TIM0_OVF:  		; Timer0 Overflow Handler
SPI_STC:   		; SPI Transfer Complete Handler
USART0_RXC:		; USART0 RX Complete Handler
USART0_DRE:		; USART0,UDR Empty Handler
USART0_TXC:		; USART0 TX Complete Handler
ADCONV:       		; ADC Conversion Complete Handler
EE_RDY:    		; EEPROM Ready Handler
ANA_COMP:  		; Analog Comparator Handler
TIM1_COMPC:		; Timer1 CompareC Handler
TIM3_CAPT: 		; Timer3 Capture Handler
TIM3_COMPA:		; Timer3 CompareA Handler
TIM3_COMPB:		; Timer3 CompareB Handler
TIM3_COMPC:		; Timer3 CompareC Handler
TIM3_OVF:  		; Timer3 Overflow Handler
USART1_RXC:		; USART1 RX Complete Handler
USART1_DRE:		; USART1,UDR Empty Handler
USART1_TXC:		; USART1 TX Complete Handler
TWI:       		; Two-wire Serial Interface Interrupt Handler
SPM_RDY:   		; SPM Ready Handler

			  rjmp RESET