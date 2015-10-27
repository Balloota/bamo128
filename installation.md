### software requirements ###
Install the GNU toolchain (avr-gcc,...) for avr8 microcontroller under linux and avrdude for monitor uploading. The latest GNU tools are hidden in avr32studio http://www.atmel.no/beta_ware currently.
If you download and unpack avr32studio in the /opt/cross directory, your environment is compatible with the bamo128 paths.<br>
Unpack bamo128xx.tar.gz. Connect your board with a programmer and the programmer and the board via USB with our pc.<br>
We use the programmer avrISPmkII for arduino boards, for other programmers change the Makefile in the bamo128 directory.<br>
<h3>bamo128 at atmega processors</h3>
Bamo128 needs 4Kword (a 16 bit) flash program memory space preferabely in the bootsection of controller (at least the routine Do_spm in file flash.asm) and 256 Byte sram (the best place for sram memory is at INTERNAL_SRAM_END for boards without external ram).<br>
In the standard installation starts bamo128 after reset in the bootsection, where the monitor is placed. The interrupt vector table is at the beginning of flash memory (address 0).<br>
Bamo128 works with interrupt (timer2 for the step and break command, timer1 for the currentTimeMilliSec variable) and burns 2 entries in the vector table.<br>
<h3>installation for arduino boards</h3>
The Makefile contains goals for burning the monitor in the board CharonII (atmega128 and externtal 32KRAM), arduino Mega (atmega1280) and arduino Duemilanove (atmega328). In a terminal window type:<br>
<table><thead><th>for arduino Mega </th><th>for arduino Duemilanove and compatible</th></thead><tbody>
<tr><td>#> make all am   </td><td>#> make all du                        </td></tr></tbody></table>



and for setting fuses in controller:<br>
<table><thead><th> arduino Mega</th><th> arduino Duemilanove or UNO</th></thead><tbody>
<tr><td> 4K word bootsection 0xF000-0xFFFF </td><td> 2K word bootsection 0x3800 - 0x3FFF</td></tr>
<tr><td>start at bootsection after reset  </td><td>  start at bootsection after reset   </td></tr>
<tr><td>#> make fuses am</td><td>#> make fuses du           </td></tr></tbody></table>


For the duemilanove the monitor starts at 0x3000 and ends at 0x3FFF.<br>
At address 0x3800 (start after reset)in monitor  is a jump to 0x3000.<br><br>
You can undo all software and fuses changes with the arduino IDE.<br>
<h3>bamo128 at other boards and for other controllers.</h3>
There are two board and processor specific files e.g. arduinomega.h and arduinomegaivtab,.asm include in boardefines.h and ivtab.asm.<br>
This files contain macros for uart,timer, external ram and the processor specific interrupt vector table.<br>
Add files for your boad and processor.<br>
Extend the Makefile with goals and macros for your target.