#ifndef __BAMODEFINES__
#define	__BAMODEFINES__

#define		VERSION		"0.07"
#define		MONSTART	LARGEBOOTSTART

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