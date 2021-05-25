// CMLS - GROUP 16
////////////////////////////////////
// SECTION 3 - CONNECTIONS SECTION
////////////////////////////////////

///////////////////
// MIDI section
///////////////////


// Inizializzo gruppi per effetti, pad e synth

(
var noteArrayL = Array.newClear(128); // array note launchpad
var noteArrayK = Array.newClear(128); // array note key
var launchpadID = MIDIClient.sources.detect { |e| e.device.containsi("Launchpad S") }.uid();
var keyboardID = MIDIClient.sources.detect { |e| e.device.containsi("Focusrite USB MIDI") }.uid();
var controlID = MIDIClient.sources.detect { |e| e.device.containsi("Launch Control") }.uid();
var loopDrumID = MIDIClient.sources.detect { |e| e.device.containsi("loopMIDI Drum") }.uid();
var loopSynthID = MIDIClient.sources.detect { |e| e.device.containsi("loopMIDI Synth") }.uid();
var selKey = 0;

MIDIClient.init;
MIDIClient.sources;           // elenco i controller in entrata e uscita
MIDIClient.destinations;
MIDIIn.connectAll;

// carico le impostazioni per il server
s.options.protocol = \tcp; // set to use tcp
s.options.bindAddress = "0.0.0.0"; // allow connections from any address
s.options.maxLogins = 2; // set to correct number of clients
s.reboot;
s.meter;
s.plotTree;

         // collego i controller
~sendOSC = NetAddr.new("192.168.1.5", 7771);    // OSC sending section
~reciveOSC = NetAddr.new("127.0.0.1", NetAddr.langPort);

~drum = Bus.audio(s, 2);     // creo gruppi di suoni
~synth = Bus.audio(s, 2);

~drum_dry_control = Bus.control(s, 1).set(1);
~drum_reverb_control = Bus.control(s, 1).set(0);     // Bus di controllo uscite parallele
~drum_delay_control = Bus.control(s, 1).set(0);
~drum_phase_control = Bus.control(s, 1).set(0);

~synth_dry_control =  Bus.control(s, 1).set(1);
~synth_reverb_control = Bus.control(s, 1).set(0);     // Bus di controllo uscite parallele
~synth_delay_control = Bus.control(s, 1).set(0);
~synth_phase_control = Bus.control(s, 1).set(0);

~sensor = Bus.control(s, 1).set(0);

~drum_dry =  Synth.new(\dry, [\inBus, ~drum, \gain ,~drum_dry_control.asMap]);
~drum_reverb = Synth.new(\reverb, [\inBus, ~drum, \gain ,~drum_reverb_control.asMap]);      // gruppi di uscite parallele
~drum_delay = Synth.new(\delay, [\inBus, ~drum,\gain ,~drum_delay_control.asMap]);
~drum_phase = Synth.new(\phasing, [\inBus, ~drum,\gain ,~drum_phase_control.asMap]);

~synth_dry =  Synth.new(\dry, [\inBus, ~synth,\gain ,~synth_dry_control.asMap]);
~synth_reverb = Synth.new(\reverb, [\inBus, ~synth,\gain ,~sensor.asMap]);      // gruppi di uscite parallele
~synth_delay = Synth.new(\delay, [\inBus, ~synth,\gain ,~synth_delay_control.asMap]);
~synth_phase = Synth.new(\phasing, [\inBus,~synth,\gain ,~synth_phase_control.asMap]);



//d = ParGroup.new;
//g = ParGroup.new;

/// inizializzo gli effetti
/*
~drum_reverb.set(\gain, 0);
~drum_delay.set(\gain, 0);
~drum_phase.set(\gain, 0);
~synth_reverb.set(\gain, 0);
~synth_delay.set(\gain, 0);
~synth_phase.set(\gain, 0);

*/
///////////////////////////// LAUNCHPAD DEBUG
["Launchpad ID", launchpadID].postln();
["Keyboard ID", keyboardID].postln();
["Launch Control ID", controlID].postln();
["Loop Midi Drum ID", loopDrumID].postln();
["Loop Midi Synth ID", loopSynthID].postln();

~luci  = MIDIOut.newByName("Launchpad S", "Launchpad S");  // per colorare il launchpad

///////////////////////////// LAUNCHPAD SOUNDS
MIDIFunc.noteOn({arg vel, note;
	["Launchpad NOTE ON", note].postln;

	if (note ==112){
		noteArrayL[note] = Synth(\kick,[\out, ~drum, \freq, note.midicps, \amp,0.4])};
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

///////////////////////////// LOOP
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

},nil,nil,loopDrumID);

MIDIFunc.noteOff({arg vel, note;
    noteArrayL[note].set(\gate, 0);
	// LUCI NOTE OFF
	~luci.noteOn(16, note, vel);
    ["Launchpad NOTE OFF", note].postln;
},nil,nil,loopDrumID);

//////////////////////// LAUNCH CONTROL CC
//////////////////////// LAUNCH CONTROL CC
MIDIFunc.cc({arg vel, note;
	var gain = vel/127;
	if (note == 21){
		~drum_dry_control.set(gain)};
	if (note == 22){
		~drum_reverb_control.set(gain)};
	if (note == 23){
		~drum_delay_control.set(gain)};
	if (note == 24){
		~drum_phase_control.set(gain)};
	if (note == 41){
		~synth_dry_control.set(gain)};
	if (note == 42){
		~synth_reverb_control.set(gain)};
	if (note == 43){
		~synth_delay_control.set(gain)};
	if (note == 44){
		~synth_phase_control.set(gain)};
	["Launch CC", note, "value", vel].postln;
},nil,nil,controlID);

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

},nil,nil,loopSynthID);

MIDIFunc.noteOff({arg vel, note;
    noteArrayK[note].set(\gate, 0);
    ["Keyboard NOTE OFF", note].postln;
},nil,nil,loopSynthID);




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
		~drum_dry_control.set(x);
	},
	'/1/fader1');

OSCdef('Drum_Reverb',
	{
		arg msg;
		x = msg[1];
		postln("Drum Rev: "+x);
		~drum_reverb_control.set(x);
	},
	'/1/fader2');

OSCdef('Drum_Delay',
	{
		arg msg;
		x = msg[1];
		postln("Drum Dly: "+x);
		~drum_delay_control.set(x);
	},
	'/1/fader3');

OSCdef('Drum_Phase',
	{
		arg msg;
		x = msg[1];
		postln("Drum Phs: "+x);
		~drum_phase_control.set(x);
	},
	'/1/fader4');

// pagina 2
OSCdef('Synth_Dry',
	{
		arg msg;
		x = msg[1];
		postln("Synth ry: "+x);
		~synth_dry_control.set(x);
	},
	'/2/fader1');

OSCdef('Synth_Reverb',
	{
		arg msg;
		x = msg[1];
		postln("Synth Rev: "+x);
		~synth_reverb_control.set(x);
	},
	'/2/fader2');

OSCdef('Synth_Delay',
	{
		arg msg;
		x = msg[1];
		postln("Synth Dly: "+x);
		~synth_delay_control.set(x);
	},
	'/2/fader3');

OSCdef('Synth_Phase',
	{
		arg msg;
		x = msg[1];
		postln("Synth Phs: "+x);
		~synth_phase_control.set(x);
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


~interface = Routine.new({
	var x;
	{
		~drum_dry_control.get({arg value; ~sendOSC.sendMsg("/1/label1", value); ~sendOSC.sendMsg("/1/fader1", value);});
		~drum_reverb_control.get({arg value; ~sendOSC.sendMsg("/1/label2", value); ~sendOSC.sendMsg("/1/fader2", value);});
		~drum_delay_control.get({arg value; ~sendOSC.sendMsg("/1/label3", value); ~sendOSC.sendMsg("/1/fader3", value);});
		~drum_phase_control.get({arg value; ~sendOSC.sendMsg("/1/label4", value); ~sendOSC.sendMsg("/1/fader4", value);});
		0.1.wait;
		~synth_dry_control.get({arg value; ~sendOSC.sendMsg("/2/label5", value); ~sendOSC.sendMsg("/2/fader1", value);});
		~sensor.get({arg value; ~sendOSC.sendMsg("/2/label6", value); ~sendOSC.sendMsg("/2/fader2", value);});
		~synth_delay_control.get({arg value; ~sendOSC.sendMsg("/2/label7", value); ~sendOSC.sendMsg("/2/fader3", value);});
		~synth_phase_control.get({arg value; ~sendOSC.sendMsg("/2/label8", value); ~sendOSC.sendMsg("/2/fader4", value);});
		0.1.wait;
	}.loop;

}).play;

)
