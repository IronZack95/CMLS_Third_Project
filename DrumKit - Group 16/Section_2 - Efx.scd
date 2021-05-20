// CMLS - GROUP 16
////////////////////////////////////
// SECTION 2 - EFFECTS SECTION
////////////////////////////////////

(
SynthDef(\wet, {arg outBus=0 , inBus;
	var input;
	input=In.ar(inBus,2); //get two channels of input starting (and ending) on bus 0
	Out.ar(outBus,input); //adds to bus 0 where original signal is already playing
}).add;

// flanger and phasing
SynthDef(\phasing, {arg outBus=0 , inBus, freq=0.2;
	var input, effect;
	input=In.ar(inBus,2); //get two channels of input starting (and ending) on bus 0
	effect= AllpassN.ar(input,0.02,SinOsc.kr(freq,0,0.01,0.01)); //max delay of 20msec
	Out.ar(outBus,effect); //adds to bus 0 where original signal is already playing
}).add;

// Delay
SynthDef(\delay, {arg outBus=0 , inBus, delaytime=0.1;
var input, effect;
input=In.ar(inBus,2); //get two channels of input starting (and ending) on bus 0
effect= DelayN.ar(input, 1,delaytime); //max delay of one second
Out.ar(outBus,effect); //adds to bus 0
}).add;

// reverb
SynthDef(\reverb, {arg outBus=0, inBus ,delaytime=0.01, decaytime=1, amp = 1;
var input;
var numc,numa,temp;
input=In.ar(inBus,2); //get two channels of input starting (and ending) on bus 0
numc = 4; // number of comb delays
numa = 6; // number of allpass delays
// reverb predelay time :
temp = DelayN.ar(input, 0.048,0.048);
temp=Mix.fill(numc,{CombL.ar(temp,0.1,rrand(0.01, 0.1),5)});
// chain of 4 allpass delays on each of two channels (8 total) :
numa.do({ temp = AllpassN.ar(temp, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1) });
// add original sound to reverb and play it :
Out.ar(outBus,amp*(0.2*temp));
}).add;
)


























(
// flanger and phasing
SynthDef(\phasing, {arg freq=0.2;
	var input, effect;
	input=In.ar(0,2); //get two channels of input starting (and ending) on bus 0
	effect= AllpassN.ar(input,0.02,SinOsc.kr(freq,0,0.01,0.01)); //max delay of 20msec
	Out.ar(0,effect); //adds to bus 0 where original signal is already playing
}).add;

// Delay
SynthDef(\delay, {arg delaytime=0.1;
var input, effect;
input=In.ar(0,2); //get two channels of input starting (and ending) on bus 0
effect= DelayN.ar(input, 1,delaytime); //max delay of one second
Out.ar(0,effect); //adds to bus 0
}).add;

// reverb
SynthDef(\reverb, {arg delaytime=0.01, decaytime=1;
var input;
var numc,numa,temp;
input=In.ar(0,2); //get two channels of input starting (and ending) on bus 0
numc = 4; // number of comb delays
numa = 6; // number of allpass delays
// reverb predelay time :
temp = DelayN.ar(input, 0.048,0.048);
temp=Mix.fill(numc,{CombL.ar(temp,0.1,rrand(0.01, 0.1),5)});
// chain of 4 allpass delays on each of two channels (8 total) :
numa.do({ temp = AllpassN.ar(temp, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1) });
// add original sound to reverb and play it :
Out.ar(0,(0.2*temp));
}).add;
)

























////                      EXPERIMENTAL


// Si muove col mouse

(

{
	var source = Impulse.ar(MouseX.kr(1,10));
	var sound, feedback;
	feedback = LocalIn.ar(1);	//one channel of feedback
	sound = source + feedback;
	LocalOut.ar(sound* MouseY.kr(0,0.9));  //feedback sound with some gain (<1 to stop feedback building up and overloading!).
	sound;
}.play
)





