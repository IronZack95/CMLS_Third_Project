// CMLS - GROUP 16
////////////////////////////////////
// SECTION 3 - CONNECTIONS SECTION
////////////////////////////////////

///////////////////
// MIDI section
///////////////////

MIDIIn.connectAll;

// LAUNCHPAD MAPPING
(
var noteArray = Array.newClear(128); // array has one slot per possible MIDI note

var numID= 2;

MIDIdef.noteOn(\myKeyDown, {arg vel, note;
    // Keyboard division to play every sound
	if (note ==112){
		noteArray[note] = Synth(\kick,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==113){
		noteArray[note] = Synth(\snare,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==114){
		noteArray[note] = Synth(\hihat,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==115){
		noteArray[note] = Synth(\clap,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};

	if (note ==96){
		noteArray[note] = Synth(\neurosnare,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==97){
		noteArray[note] = Synth(\technokick,[ \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==98){
		noteArray[note] = Synth(\gabberkick,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==99){
		noteArray[note] = Synth(\cowbell,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};

	if (note ==80){
		noteArray[note] = Synth("blueNoise",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==81){
		noteArray[note] = Synth(\technokick,[ \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==82){
		noteArray[note] = Synth(\gabberkick,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==83){
		noteArray[note] = Synth(\cowbell,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};

	// piano
	//noteArray[note] = Synth("harpsichord2",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth("organDonor",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);

	//PAD
	//noteArray[note] = Synth(\midSideSaw,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth("arpoctave",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);

	noteArray[note] = Synth(\feedbackPad1,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth(\feedbackPad3,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth("sawSynth",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth(\superSaw,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth("moogBass",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth(\pluck,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);


	["Launchpad NOTE ON", note].postln;

},nil,nil,numID);

MIDIdef.noteOff(\myKeyUp, {arg vel, note;
    noteArray[note].set(\gate, 0);
    ["Launchpad NOTE OFF", note].postln;
},nil,nil,numID);
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
