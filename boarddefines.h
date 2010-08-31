#ifndef __BAMODEFINES__
#define	__BAMODEFINES__

#define		VERSION		"0.07"

#ifdef	CHARON
#include "charondefines.h"
#endif
#ifdef ARDUINOMEGA
#include "arduinomegadefines.h"
#endif

#ifndef TESTVERSION
#define		MONSTART	LARGEBOOTSTART
#else
#define		MONSTART	0x80		// for tests, step-command doesnt work
#endif // TESTVERSION



#endif	//bamodefines