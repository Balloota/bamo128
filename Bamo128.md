# Bamo128 #
is a resident monitor program for AVR8 microcontroller.<br> It is written in assembler and you can burn it with an appropriate programmer (avrIspmkII, stk500,..) and programming software (arvdude) on the microcontroller. After reset the monitor starts and waits for interaction with the user over serial communication lines (RS232, USB) and a pc-terminal software. arduinokermit <a href='http://minikermit.googlecode.com'>http://minikermit.googlecode.com</a> is a terminal program well adapted for bamo128.<br>
After reset (exactly about 1/2 second after reset - in this time bamo128 waits for external programmer in "ardiuno style") you see in the terminal window the greetings and the prompt line of bamo128:<br><br>
<pre><code>______________BAMo128 Version:0.08________________<br>
__written from students of the BA Berlin for the ArduinoMega__<br>
BAMO128#&gt;<br>
</code></pre>
<h3>Bamo128 commands</h3>
<table><thead><th>'a'  </th><th> authors</th></thead><tbody>
<tr><td>'h'    </td><td> help   </td></tr>
<tr><td>'m' sta </td><td> Ram display/modify</td></tr>
<tr><td>'e' sta </td><td> eeprom display/modify</td></tr>
<tr><td>'f' sta </td><td> flash display</td></tr>
<tr><td>'r'     </td><td> register/flags display/modify ('R')</td></tr>
<tr><td>'w'     </td><td> binary file (executable program) load at flash address 0</td></tr>
<tr><td>'W'  </td><td> binary file (executable program) load at 'adr'</td></tr>
<tr><td>'S'  </td><td> data file load at 'adr' in sram</td></tr>
<tr><td>'E'  </td><td> data file load at 'adr' in eeprom</td></tr>
<tr><td>'g' adr </td><td> starts program at adr</td></tr>
<tr><td>'s' adr </td><td>step-mode at adr(realzed with timer2-interrupt)</td></tr>
<tr><td>        </td><td>repeated 'step' -> type simply -LFCR-</td></tr>
<tr><td>'x' adr </td><td>starts program at adr up to breakpoint (realized with timer2-interrupt)</td></tr>
<tr><td>'b'     </td><td>set/clear breakpoints</td></tr>
<tr><td>'u' adr </td><td>disassemble</td></tr>
<tr><td>'c'  </td><td> copy ram/ram, ram/flash, flash/ram, ram/eeprom, eeprom/ram,eeprom/eeprom</td></tr>