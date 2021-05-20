// CMLS - GROUP 16
////////////////////////////////////
// SECTION 3 - CONNECTIONS SECTION
////////////////////////////////////

///////////////////
// MIDI section
///////////////////
s.boot;

// Inizializzo gruppi per effetti, pad e synth

(
MIDIIn.connectAll;
~drum = Bus.audio(s, 2);     // gruppi di suoni
~synth = Bus.audio(s, 2);
~wet =  Synth.new(\wet, [\inBus, ~drum]);
~reverb = Synth.new(\reverb, [\inBus, ~drum]);      // gruppi di uscite parallele
~delay = Synth.new(\delay, [\inBus, ~drum]);
~phase = Synth.new(\phasing, [\inBus, ~drum]);
//d = ParGroup.new;
//g = ParGroup.new;
)

(
g.freeAll;
d.freeAll;
g.free;
d.free;
~reverb.free;
~delay.free;
)

// LAUNCHPAD MAPPING
(

var noteArray = Array.newClear(128); // array has one slot per possible MIDI note

var numID= 2;

MIDIdef.noteOn(\myKeyDown, {arg vel, note;
    // Keyboard division to play every sound
	if (note ==112){
		noteArray[note] = Synth(\kick,[\out, ~drum, \freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==113){
		noteArray[note] = Synth(\snare,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==114){
		noteArray[note] = Synth(\hihat,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==115){
		noteArray[note] = Synth(\clap,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};

	if (note ==96){
		noteArray[note] = Synth(\neurosnare,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==97){
		noteArray[note] = Synth(\technokick,[\out, ~drum, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==98){
		noteArray[note] = Synth(\gabberkick,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==99){
		noteArray[note] = Synth(\cowbell,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};

	if (note ==80){
		noteArray[note] = Synth(\blueNoise,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==81){
		noteArray[note] = Synth(\technokick,[\out, ~drum, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==82){
		noteArray[note] = Synth(\gabberkick,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==83){
		noteArray[note] = Synth(\cowbell,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};

	// piano
	//noteArray[note] = Synth("harpsichord2",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth("organDonor",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);

	//PAD
	//noteArray[note] = Synth(\midSideSaw,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth("arpoctave",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);

	//noteArray[note] = Synth(\feedbackPad1,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth(\feedbackPad3,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth("sawSynth",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth(\superSaw,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth("moogBass",[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	//noteArray[note] = Synth(\pluck,[\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);

	if (note < 80){
		noteArray[note] = Synth(\sawSynth,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
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
		synth1.set(\amp,x);
	},
	'/1/toggle1');
)
///////////////////
// Serial section
///////////////////

~port = SerialPort.new("COM3", 9600);
(
~charArray = [ ];
~getValues = Routine.new({
	var ascii;
	var address = 0; var last_address = 0;
	var data = 0; var last_data = 0;
	{
		ascii = ~port.read.asAscii; // read è una funzione Blocking
		if(ascii.isDecDigit){~charArray = ~charArray.add(ascii)};
		if(ascii == $a){
			~val= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
			data = ~val;
			'd: '.post();
			~val.postln();
		};
		if(ascii == $d){
			~val= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
			address = ~val;
			'a: '.post();
			~val.postln();
		};
		// LOGICA
		if(address != last_address || data != last_data){
			last_data = data;
			last_address = address;
			if(address == 100){
				if( data < 70,{
					//x.set(\freq1, data*4,\freq2, data*5);
					~reverb.set(\amp, 1-data/70)},{~reverb.set(\amp, 1);'over 200'.postln()};);
			}
		};
	}.loop;
}).play;
)
(
x = SynthDef("tutorial-map", { arg freq1 = 440, freq2 = 440;
    Out.ar(0, SinOsc.ar([freq1, freq2], 0, 0.1));
}).play(s);
)

// CLOSE CONNECTIONS
(
~getValues.stop;
~port.close;
)