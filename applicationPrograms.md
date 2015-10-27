You can upload application programs bamo128 from the arduino IDE or with the 'w' and 'W' - command from monitor. Programs are loaded at flash address 0 normally.<br>
This application programs overwrite the interrupt vector table at address 0 and if you activate the timer1 form bamo128 in "mainloop.asm" the system crashes because interrupts are no more catched in the interrupt service routine of bamo128. <br>
It crashes also, if you use the monitor 's' (step) or 'x'(start with breakpoint because it is realized with time2 interrupt in bamo128.<br>
But you can avoid this, if you in your C/C++/Arduino-sourcecode insert this lines (for atmega1280 or atmega328):<br>
<pre><code>#define	BYTES(word)	((word)*2)<br>
#define	STRING(a,b)	#a" "#b<br>
#define	INLINEASM(a,b)	STRING(a,b)<br>
<br>
#ifdef  __AVR_ATmega1280__		// arduinoMega<br>
#define	LARGEBOOTSTART	0xf000<br>
#define	BOARDRAMEND	0x2200<br>
#define	MONSTART	LARGEBOOTSTART<br>
#elif __AVR_ATmega328P__		// arduinoDuemilanove<br>
#define	LARGEBOOTSTART	0x3000<br>
#define	BOARDRAMEND	0x900<br>
#define	MONSTART	LARGEBOOTSTART<br>
#endif	<br>
#define MONRAM		(BOARDRAMEND-0x100)<br>
#define	SYSTIMEMILLISEC	(MONRAM+0x40)<br>
#define saveCPU		BYTES(LARGEBOOTSTART+62)	// time2Comp interrupt<br>
#define mySysClock      BYTES(LARGEBOOTSTART+56)	// timer1 overflow int<br>
<br>
// monitor interrupt für step ...<br>
ISR(TIMER2_COMPA_vect) __attribute__ ((naked));<br>
ISR(TIMER2_COMPA_vect) {asm volatile  (INLINEASM(jmp,saveCPU));}<br>
<br>
 /* monitor interrupt for sysclock millisec */<br>
ISR(TIMER1_COMPA_vect) __attribute__ ((naked));<br>
ISR(TIMER1_COMPA_vect) {asm volatile  (INLINEASM(jmp,mySysClock));}<br>
</code></pre>
In asm set equivalent jump entries for interrupts with '.org' pseudo code directives.<br>
The monitor needs 256 bytes ram. Sketches/C/C++ programs use the whole ram with the stacksegment in the upper part normally. You can shift the stacksegment downwards:<br>
<pre><code>void code_init2() __attribute__ ((naked, section (".init2")));<br>
<br>
/* !!! never call this function !!! */<br>
void code_init2 (void)<br>
{<br>
#ifdef __AVR_ATmega1280__		// arduinoMega<br>
   SP = 0x2100;<br>
#elif __AVR_ATmega328P__		// arduinoDuemilanove<br>
   SP = 0x800; <br>
#endif<br>
}<br>
</code></pre>
an equivalent effect (arduinoMega) you get with a linker option:<br>
-Wl,--defsym=stack=0x802100<br>
and you save the monitor variables for overwriting. With "return" the application programs go back to the monitor.<br>
<h3>Use of monitor functions and variables in application programs</h3>
The monitor contains useful variables and functions e.g. currentTimeMilliSec<br>
or conIn and conOut, the serial byte input and output.<br>
You can use many in your application program.<br>
Most public functions are C/C++ compatible (parameter passing, return value, use of registers,...).<br>
Your sketch, C/C++ or asm program must make known this variables and functions over addresses.<br>
Bamo128 contains a jump table to this functions at the beginning (see bamo128.asm). So application can use fix addresses even if the monitor is updated and routines disarranges in monitor.<br>
You can use a linker script to tell the linker where useful functions/variables are im monitor:<br>
Example linkerscript link1280.lds for atmega1280:<br>
<pre><code>/* hi this is a linker script */<br>
/* monitor functions for C applications */<br>
mainLoop	= 0x1e004;	<br>
/* (LARGEBOOTSTART+2) ; Ruecksprung in Monitor aus Programm mit "ret" */<br>
conIn		= 0x1e008; 	/* (LARGEBOOTSTART+4) */<br>
conOut		= 0x1e00c;	/* (LARGEBOOTSTART+6) */<br>
conStatInT	= 0x1e010;	/* (LARGEBOOTSTART+8) */<br>
outFlashText 	= 0x1e018;	/* (LARGEBOOTSTART+12) */<br>
exit 		= 0x1e004;	/* mainLoop */<br>
saveCPU		= 0x1e07c;	/* saveCPU step mod */<br>
mySysClock	= 0x1e070;	/* timer ms  F056*/<br>
startTimer1	= 0x1e074;      /* (LARGEBOOTSTART+58) */<br>
<br>
sysTime		= 0x7f40;	/* systime milliSec 4 bytes little endian */<br>
</code></pre>
(The GNU environment works with byte addresses and the linker scripts runs not trough the preprocessor.)<br><br>
Another possibility is to tell the compiler what addresses are used:<br>
<pre><code>char (*conIn)()		=(void*)(LARGEBOOTSTART+4);<br>
void (*conOut)(char)	=(void*)(LARGEBOOTSTART+6);<br>
#define	SYSTIMEMILLISEC	(MONRAM+0x40)<br>
</code></pre>