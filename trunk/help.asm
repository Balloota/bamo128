/*
* HWR-Berlin, Fachbereich Berufsakademie, Fachrichtung Informatik
* See the file "license.terms" for information on usage and redistribution of this file.
*/
// autor:  Christian Schmidt	;###   AUTOREN   ### 
// date of creation: 		08.03.2006
// date of last modification	08.03.2006
// inputs:			
// outputs:			
// affected regs. flags:	
// used subroutines:		outFlashText
// changelog

//.global	showAuthors
.global	showHelp
/*
showAuthors:	rcall	outFlashText
.string		"\r\n\
		Funktion________________________Autoren_________________Firma\r\n\
		E/A Routinen\t\t\tMarek Mueller (ib-bank-systems)\r\n\
		Terminal/Coursersteuerung \tAndre Kallweit (ib-bank-systems)\r\n\
		Kovertierungen,Hilfe Autoren \tChristian Schmidt (IBB)\r\n\
		copy\t\t\t\tInes Moosdorf \t(Alcatel)\r\n\
		go, bamo128\t\t\tMathias Boehme \t(Schering)\r\n\
		step,break\t\t\tHenning Schmidt (Alcatel)\r\n\
		SRAM-routines\t\t\tAndre Hoehn (CoMedServ), Anna Schobert (BSP) 2009\r\n\
		EEPROM routines\t\t\tMax Dubiel (HMI)\r\n\
		Flash anzeigen\t\t\tTilo Kussatz (DeTeWe)\r\n\
		Register-routines\t\tRaik Guelow (HMI), Robert Janisch (BSP) 2009"
	.align 1		
		ret
*/
// autor:  			Christian Schmidt									;###   Help   ### 
// date of creation: 		08.03.2006
// date of last modification	08.03.2006
// inputs:			
// outputs:			
// affected regs. flags:	
// used subroutines:		outFlashText
// changelog

showHelp:	rcall	outFlashText
.string	"\r\n__________BAMo128 Hilfe__________\r\n\
<a>\t\tAuthors display\r\n\
<e> [STA]\tEeprom display/modify\r\n\
<f> [STA]\tFlash display\r\n\
<m> [STA]\tMemory (SRAM) display/modify\r\n\
<h>\t\tHelp\r\n\
<g> [STA]\tGo with start address\r\n\
<s> [STA]\tnum\tnum step(s) from STA\r\n\
<x> [STA]\tExecute from STA upto breakpoint\r\n\
<b>\t\tBreakpoints display/modify\r\n\
<r>\t\tRegister display/modify\r\n\
<c> ss,se,ee,es,sf,fs: sta enda desta copy from/to sram,eeprom flash\r\n\
<w>\t\tuploading a cob-file to the charonII from PC\r\n\
<j> [FADDR}\twrite pages in flash\r\n\
<u> [STA]\tdisassmble\r\n"
.align 1		
		ret
