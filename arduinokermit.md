arduinokermit is a linux-terminal program for communication and uploading files at microcontroller.<br>
Download arduinokermit.tar.gz from <a href='http://minikermit.googlecode.com'>http://minikermit.googlecode.com</a>.<br>
Unpack it and compile arduinokermit.c:<br>
#>g++ arduinokermit.c -lncurses -oarduinokermit<br>
Connect the arduinoboard (or other AVR8 board) -with bamo128 uploaded- via USB to the PC and start arduinokermit:<br>
#./arduinokermit<br>
You can now use the monitor commands, upload programs and start application programs.<br>
Applications are able to communicate via serial port with arduinokermit as well.<br>