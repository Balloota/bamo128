#ifndef __BAMODEFINES__
#define	__BAMODEFINES__

#define		VERSION		"0.08"
#define		MONSTART	LARGEBOOTSTART

/* SW_MAJOR and MINOR needs to be updated from time to time to avoid warning message from AVR Studio */
#define HW_VER	 0x02
#define SW_MAJOR 0x01
#define SW_MINOR 0x12

/* define various device id's */
/* manufacturer byte is always the same */
#define SIG1	0x1E	// Yep, Atmel is the only manufacturer of AVR micros.  Single source :(


#ifdef	CHARON
#include "charondefines.h"
#endif

#ifdef ARDUINOMEGA
#include "arduinomegadefines.h"
#endif

#ifdef ARDUINODUEMILANOVE
#include "arduino328pdefines.h"
#endif

.equ		bdteiler,(CPUFREQUENZ/(16*BAMOBAUDRATE)-1)	; Baud-Divider

#endif	//bamodefines