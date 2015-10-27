You can use kermit, the known terminal interaction and file transfer program, to  communicate with bamo128 (without data/program uploading).<br>
Save an initialization file in your home dir:<br>
<pre><code>; Line properties<br>
set modem type             none ; Direct connection<br>
set line           /dev/ttyUSB0 ; Device file<br>
set speed                 57600 ; Line speed<br>
set carrier-watch           off ; No carrier expected<br>
set handshake              none ; No handshaking<br>
set flow-control           none ; No flow control<br>
<br>
; Communication properties<br>
robust                          ; Most robust transfer settings macro<br>
set receive packet-length  1000 ; Max pack len remote system should use<br>
set send packet-length     1000 ; Max pack len local system should use<br>
set window                   10 ; Nbr of packets to send until ack<br>
<br>
; File transfer properties<br>
set file type            binary ; All files transferred are binary<br>
set file names          literal ; Don't modify filenames during xfers<br>
<br>
<br>
Connect your arduino via USB with the pc and start kermit in a terminal window:&lt;br&gt;<br>
<br>
#&gt; kermit -c<br>
</code></pre>