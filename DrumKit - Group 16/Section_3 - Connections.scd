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
MIDIClient.init;
MIDIClient.sources;           // elenco i controller
MIDIClient.destinations;
MIDIIn.connectAll;          // collego i controller
~drum = Bus.audio(s, 2);     // gruppi di suoni
~synth = Bus.audio(s, 2);

~drum_wet =  Synth.new(\wet, [\inBus, ~drum]);
~drum_reverb = Synth.new(\reverb, [\inBus, ~drum]);      // gruppi di uscite parallele
~drum_delay = Synth.new(\delay, [\inBus, ~drum]);
~drum_phase = Synth.new(\phasing, [\inBus, ~drum]);

~synth_wet =  Synth.new(\wet, [\inBus, ~synth]);
~synth_reverb = Synth.new(\reverb, [\inBus, ~synth]);      // gruppi di uscite parallele
~synth_delay = Synth.new(\delay, [\inBus, ~synth]);
~synth_phase = Synth.new(\phasing, [\inBus,~synth]);
//d = ParGroup.new;
//g = ParGroup.new;
)

(

var launchpadID = MIDIClient.sources.detect { |e| e.device.containsi("Launchpad S") }.uid();
var keyboardID = MIDIClient.sources.detect { |e| e.device.containsi("Focusrite USB MIDI") }.uid();
var noteArrayL = Array.newClear(128); // array has one slot per possible MIDI note
var noteArrayK = Array.newClear(128); // array has one slot per possible MIDI note

    // LAUNCHPAD SOUNDS
["Launchpad ID", launchpadID].postln();
["Keyboard ID", keyboardID].postln();
m = MIDIOut.newByName("Launchpad S", "Launchpad S");  // per colorare il launchpad
//m.noteOn(16, 112, 127);
//m.noteOff(16,112,0);
MIDIFunc.noteOn({arg vel, note;
	["Launchpad NOTE ON", note].postln;

	if (note ==112){
		noteArrayL[note] = Synth(\kick,[\out, ~drum, \freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==113){
		noteArrayL[note] = Synth(\snare,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==114){
		noteArrayL[note] = Synth(\hihat,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==115){
		noteArrayL[note] = Synth(\clap,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==96){
		noteArrayL[note] = Synth(\neurosnare,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==97){
		noteArrayL[note] = Synth(\technokick,[\out, ~drum, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==98){
		noteArrayL[note] = Synth(\gabberkick,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==99){
		noteArrayL[note] = Synth(\cowbell,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==80){
		noteArrayL[note] = Synth(\blueNoise,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==81){
		noteArrayL[note] = Synth(\technokick,[\out, ~drum, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==82){
		noteArrayL[note] = Synth(\gabberkick,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note ==83){
		noteArrayL[note] = Synth(\cowbell,[\out, ~drum,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};

	// LUCI NOTE ON
	m.noteOn(16, note, vel);

},nil,nil,launchpadID);

MIDIFunc.noteOff({arg vel, note;
    noteArrayL[note].set(\gate, 0);
	// LUCI NOTE OFF
	m.noteOn(16, note, vel);
    ["Launchpad NOTE OFF", note].postln;
},nil,nil,launchpadID);

/// KEYBOARD MIDI

MIDIFunc.noteOn({arg vel, note;

	if (note < 60){
		noteArrayK[note] = Synth(\sawSynth,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note >= 60 && note <= 80){
		noteArrayK[note] = Synth(\pluck,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (note > 80){
		noteArrayK[note] = Synth(\feedbackPad3,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
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

	["Keyboard NOTE ON", note].postln;

},nil,nil,keyboardID);

MIDIFunc.noteOff({arg vel, note;
    noteArrayK[note].set(\gate, 0);
    ["Keyboard NOTE OFF", note].postln;
},nil,nil,keyboardID);

)
///////////////////
// OSC section
///////////////////
(
OSCdef('Drum_Wet',
	{
		arg msg;
		x = msg[1];
		postln("Drum Wet: "+x);
		~drum_wet.set(\gain,x/10);
	},
	'/1/fader1');

OSCdef('Drum_Reverb',
	{
		arg msg;
		x = msg[1];
		postln("Drum Rev: "+x);
		~drum_reverb.set(\gain,x/10);
	},
	'/1/fader2');

OSCdef('Drum_Delay',
	{
		arg msg;
		x = msg[1];
		postln("Drum Dly: "+x);
		~drum_delay.set(\gain,x/10);
	},
	'/1/fader3');

OSCdef('Drum_Phase',
	{
		arg msg;
		x = msg[1];
		postln("Drum Phs: "+x);
		~drum_phase.set(\gain,x/10);
	},
	'/1/fader4');
// pagina 2
OSCdef('Synth_Wet',
	{
		arg msg;
		x = msg[1];
		postln("Synth Wet: "+x);
		~synth_wet.set(\gain,x);
	},
	'/2/fader1');

OSCdef('Synth_Reverb',
	{
		arg msg;
		x = msg[1];
		postln("Synth Rev: "+x);
		~synth_reverb.set(\gain,x);
	},
	'/2/fader2');

OSCdef('Synth_Delay',
	{
		arg msg;
		x = msg[1];
		postln("Synth Dly: "+x);
		~synth_delay.set(\gain,x);
	},
	'/2/fader3');

OSCdef('Synth_Phase',
	{
		arg msg;
		x = msg[1];
		postln("Synth Phs: "+x);
		~synth_phase.set(\gain,x);
	},
	'/2/fader4');

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
~reverb.set(\amp, 0.5)
// CLOSE CONNECTIONS
(
~getValues.stop;
~port.close;
)