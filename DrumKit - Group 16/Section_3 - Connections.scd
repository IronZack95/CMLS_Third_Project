// CMLS - GROUP 16
////////////////////////////////////
// SECTION 3 - CONNECTIONS SECTION
////////////////////////////////////

///////////////////
// MIDI section
///////////////////

MIDIIn.connectAll;

(
var noteArray = Array.newClear(128); // array has one slot per possible MIDI note



MIDIdef.noteOn(\myKeyDown, {arg vel, note;
    // Keyboard division to play every sound
    if (note < 50){
        noteArray[note] = Synth("spacey",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
    if (note>50){
        noteArray[note] = Synth(\pluck,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
    ["NOTE ON", note].postln;
});



MIDIdef.noteOff(\myKeyUp, {arg vel, note;
    noteArray[note].set(\gate, 0);
    ["NOTE OFF", note].postln;
});
)

///////////////////
// OSC section
///////////////////
(
OSCdef('OSCreceiver3',
	{
		arg msg;
		x = msg[1];
		postln("OSC: "+x);
		//synth1.set(\amp,x);
	},
	'/1/fader1');
)
///////////////////
// Serial section
///////////////////

~port = SerialPort.new("COM3", 9600);
(
~charArray = [ ];
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii; // read è una funzione Blocking
		if(ascii.isDecDigit){~charArray = ~charArray.add(ascii)};
		if(ascii == $a){
			~val= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
			'a: '.post();
			~val.postln();
		};
		if(ascii == $d){
			~val= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
			'd: '.post();
			~val.postln();
		};
	}.loop;
}).play;
)

// CLOSE CONNECTIONS
~getValues.stop;
~port.close;ARD
