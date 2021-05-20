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
var noteArrayL = Array.newClear(128); // array note launchpad
var noteArrayK = Array.newClear(128); // array note key
var launchpadID = MIDIClient.sources.detect { |e| e.device.containsi("Launchpad S") }.uid();
var keyboardID = MIDIClient.sources.detect { |e| e.device.containsi("Focusrite USB MIDI") }.uid();
var controlID = MIDIClient.sources.detect { |e| e.device.containsi("Launch Control") }.uid();
var selKey = 0;

         // collego i controller
~sendOSC = NetAddr.new("192.168.1.5", 7771);    // OSC sending section
~reciveOSC = NetAddr.new("127.0.0.1", NetAddr.langPort);

~drum = Bus.audio(s, 2);     // creo gruppi di suoni
~synth = Bus.audio(s, 2);

~drum_dry =  Synth.new(\dry, [\inBus, ~drum]);
~drum_reverb = Synth.new(\reverb, [\inBus, ~drum]);      // gruppi di uscite parallele
~drum_delay = Synth.new(\delay, [\inBus, ~drum]);
~drum_phase = Synth.new(\phasing, [\inBus, ~drum]);

~synth_dry =  Synth.new(\dry, [\inBus, ~synth]);
~synth_reverb = Synth.new(\reverb, [\inBus, ~synth]);      // gruppi di uscite parallele
~synth_delay = Synth.new(\delay, [\inBus, ~synth]);
~synth_phase = Synth.new(\phasing, [\inBus,~synth]);
//d = ParGroup.new;
//g = ParGroup.new;

///////////////////////////// LAUNCHPAD DEBUG
["Launchpad ID", launchpadID].postln();
["Keyboard ID", keyboardID].postln();
["Launch Control ID", controlID].postln();

~luci  = MIDIOut.newByName("Launchpad S", "Launchpad S");  // per colorare il launchpad

///////////////////////////// LAUNCHPAD SOUNDS
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
	~luci.noteOn(16, note, vel);

},nil,nil,launchpadID);

MIDIFunc.noteOff({arg vel, note;
    noteArrayL[note].set(\gate, 0);
	// LUCI NOTE OFF
	~luci.noteOn(16, note, vel);
    ["Launchpad NOTE OFF", note].postln;
},nil,nil,launchpadID);

//////////////////////// LAUNCH CONTROL CC
MIDIFunc.cc({arg vel, note;
	var gain = vel/127;
	if (note == 21){
		~drum_dry.set(\gain,gain); ~sendOSC.sendMsg("/1/fader1", gain)};
	if (note == 22){
		~drum_reverb.set(\gain,gain); ~sendOSC.sendMsg("/1/fader2", gain)};
	if (note == 23){
		~drum_delay.set(\gain,gain); ~sendOSC.sendMsg("/1/fader3", gain)};
	if (note == 24){
		~drum_phase.set(\gain,gain); ~sendOSC.sendMsg("/1/fader4", gain)};
	if (note == 41){
		~synth_dry.set(\gain,gain); ~sendOSC.sendMsg("/2/fader1", gain)};
	if (note == 42){
		~synth_reverb.set(\gain,gain); ~sendOSC.sendMsg("/2/fader2", gain)};
	if (note == 43){
		~synth_delay.set(\gain,gain); ~sendOSC.sendMsg("/2/fader3", gain)};
	if (note == 44){
		~synth_phase.set(\gain,gain); ~sendOSC.sendMsg("/2/fader4", gain)};
	["Launch CC", note, "value", vel].postln;
},nil,nil,controlID);

MIDIFunc.noteOff({arg vel, note;
    noteArrayL[note].set(\gate, 0);
	// LUCI NOTE OFF
	~luci.noteOn(16, note, vel);
    ["Launchpad NOTE OFF", note].postln;
},nil,nil,launchpadID);

/////////////////////// KEYBOARD MIDI

MIDIFunc.noteOn({arg vel, note;

	if (selKey == 0){       // DEFAULT SYNTH
		noteArrayK[note] = Synth(\sawSynth,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
	~sendOSC.sendMsg("/2/synth", "Saw Synth")};
	if (selKey == 1){
		noteArrayK[note] = Synth(\harpsichord2,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (selKey == 2){
		noteArrayK[note] = Synth(\feedbackPad1,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (selKey == 3){
		noteArrayK[note] = Synth(\midSideSaw,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};
	if (selKey == 4){
		noteArrayK[note] = Synth(\arpoctave,[\out, ~synth ,\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)])};

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

///////////////////
// OSC section
///////////////////

~sendOSC.sendMsg("/1/label1", "Dry");   // Inizializzo i parametri dell'editor
~sendOSC.sendMsg("/1/label2", "Rev");
~sendOSC.sendMsg("/1/label3", "Dly");
~sendOSC.sendMsg("/1/label4", "Phs");
~sendOSC.sendMsg("/2/label1", "Dry");
~sendOSC.sendMsg("/2/label2", "Rev");
~sendOSC.sendMsg("/2/label3", "Dly");
~sendOSC.sendMsg("/2/label4", "Phs");
~sendOSC.sendMsg("/2/synth", "S  Y  N  T  H");
~sendOSC.sendMsg("/2/label5", 0.0);
~sendOSC.sendMsg("/2/label6", 0.0);
~sendOSC.sendMsg("/2/label7", 0.0);
~sendOSC.sendMsg("/2/label8", 0.0);
~sendOSC.sendMsg("/1/fader1", 0);
~sendOSC.sendMsg("/1/fader2", 0);
~sendOSC.sendMsg("/1/fader3", 0);
~sendOSC.sendMsg("/1/fader4", 0);
~sendOSC.sendMsg("/1/fader5", 0);
~sendOSC.sendMsg("/2/fader1", 0);
~sendOSC.sendMsg("/2/fader2", 0);
~sendOSC.sendMsg("/2/fader3", 0);
~sendOSC.sendMsg("/2/fader4", 0);
~sendOSC.sendMsg("/2/fader5", 0);
~sendOSC.sendMsg("/1/toggle1", 0);
~sendOSC.sendMsg("/1/toggle2", 0);
~sendOSC.sendMsg("/1/toggle3", 0);
~sendOSC.sendMsg("/1/toggle4", 0);
~sendOSC.sendMsg("/1/toggle5", 0);
~sendOSC.sendMsg("/2/toggle1", 0);
~sendOSC.sendMsg("/2/toggle2", 0);
~sendOSC.sendMsg("/2/toggle3", 0);
~sendOSC.sendMsg("/2/toggle4", 0);
~sendOSC.sendMsg("/2/toggle5", 0);


OSCdef('Drum_Dry',
	{
		arg msg;
		x = msg[1];
		postln("Drum Dry: "+x);
		~drum_dry.set(\gain,x/10);
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
OSCdef('Synth_Dry',
	{
		arg msg;
		x = msg[1];
		postln("Synth ry: "+x);
		~synth_dry.set(\gain,x);
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

OSCdef('Synth_Toggle1',
	{
		arg msg;
		x = msg[1];
		postln("TOGGLE Synth: 1");
		if(x==1,{selKey = 1;~sendOSC.sendMsg("/2/synth", "Harpsichord");},{selKey = 0} )
	},
	'/2/toggle1');

OSCdef('Synth_Toggle2',
	{
		arg msg;
		x = msg[1];
		postln("TOGGLE Synth: 2");
		if(x==1,{selKey = 2;~sendOSC.sendMsg("/2/synth", "Feedback Pad 1");},{selKey = 0} )
	},
	'/2/toggle2');

OSCdef('Synth_Toggle3',
	{
		arg msg;
		x = msg[1];
		postln("TOGGLE Synth: 3");
		if(x==1,{selKey = 3;~sendOSC.sendMsg("/2/synth", "Mid - Side - Saw");},{selKey = 0} )
	},
	'/2/toggle3');

OSCdef('Synth_Toggle4',
	{
		arg msg;
		x = msg[1];
		postln("TOGGLE Synth: 4");
		if(x==1,{selKey = 4;~sendOSC.sendMsg("/2/synth", "A R P Octave");},{selKey = 0})
	},
	'/2/toggle4');

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
				if( data < 100,{
					~synth_reverb.set(\gain, data/100)},{~synth_reverb.set(\gain, 1);'over 200'.postln()};);

			}
		};
	}.loop;
}).play;
)
/*
(
x = SynthDef("tutorial-map", { arg freq1 = 440, freq2 = 440;
    Out.ar(0, SinOsc.ar([freq1, freq2], 0, 0.1));
}).play(s);
)
*/
// CLOSE CONNECTIONS
(
~getValues.stop;
~port.close;
)