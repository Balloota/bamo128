_"When I was your age, we had 8 bit CPUs and assembler! And we liked it! And we didn't complain!"_<br>
above is "cut -> copy -> paste -> modify" from <a href='http://www.ethernut.de/en'>http://www.ethernut.de/en</a> <i><br></i><br><br>
Bamo128 is a resident monitor program for AVR8 microcontrollers. The monitor is written in assembler (GNU toolchain: avr-as) and communicates with the host-PC via a serial interface with an appropriate terminal program (preferably arduinokermit or minikermit from <a href='http://minikermit.googlecode.com'>http://minikermit.googlecode.com</a>).<br>
With bamo128 you can:<br>
- visit/modify/copy the different memories of the AVR8 microcontroller<br>
- load program in flash (with the bootloader of bamo128 over serial port) and execute (also in step-mode and with break-points) asm- and C- programs<br>
- visit and modify cpu-state (flags, regs,...)<br>
- disassemble flash instructions.<br>
- load data in eeprom and sram<br>
Useful monitor functions can be linked to external ASM/C-programs with a linker script.<br>
For this function Bamo128 needs 4 KWords (8K Bytes) of flash memory advantageously in the boot section of the microcontroller and about 256 bytes ram for monitor variables (MONRAM).<br>
In version 06 and later we use bamo128 at boards with the atmega128 (CharonII with 32K external RAM and the Mica2 without external RAM), the atmega1280 on the ArduinoMega board and the atmega328 (ArduinoDuemilanove).<br>
With bamo128 you can upload Arduino software in binary format as well.<br>
<b>You can use Bamo128 as bootloader and comfortable monitor in an arduino environment. The bootloader works fine together with the arduino development environment (linux or windows).</b>