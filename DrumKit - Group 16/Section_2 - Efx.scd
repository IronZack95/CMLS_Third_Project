// CMLS - GROUP 16
////////////////////////////////////
// SECTION 2 - EFFECTS SECTION
////////////////////////////////////


// chorus

(



{
	var source;
	var fx;
	var n=10;

	source= EnvGen.ar(Env([0,1,0],[0.1,0.5]),Impulse.kr(2))*Saw.ar(440,0.5);

	fx= Mix.fill(n, {

		var maxdelaytime= rrand(0.01,0.03);

		var half= maxdelaytime*0.5;

		var quarter= maxdelaytime*0.25;



		//%half+(quarter*LPF.ar(WhiteNoise.ar,rrand(1.0,10)))

		DelayC.ar(source, maxdelaytime, LFNoise1.kr(Rand(5,10),0.01,0.02) )


	});

	fx

}.play


// Si muove col mouse

(



)

// flanger and phasing

{SinOsc.ar(ControlDur.ir.reciprocal)*0.1}.play
(

SynthDef(\fxexamplephasing, {arg freq=0.2;

	var input, effect;



	input=In.ar(0,2); //get two channels of input starting (and ending) on bus 0

	effect= AllpassN.ar(input,0.02,SinOsc.kr(freq,0,0.01,0.01)); //max delay of 20msec



	Out.ar(0,effect); //adds to bus 0 where original signal is already playing

}).add;

)

x.free

x= Synth.head(a, \continuous);

y= Synth.tail(a, \fxexamplephasing);

y.set(\freq, 0.1)

y.set(\freq, 1)

y.free





// Delay
(

SynthDef(\fxexampledelay, {arg delaytime=0.1;

var input, effect;



input=In.ar(0,2); //get two channels of input starting (and ending) on bus 0



effect= DelayN.ar(input, 1,delaytime); //max delay of one second



Out.ar(0,effect); //adds to bus 0

}).add;

)

x.free;

x = Synth.head(a, \impulse);

y= Synth.tail(a, \fxexampledelay);

y.free;

y= Synth.tail(a, \fxexampledelay, [\delaytime, 0.4]);

y.free;



// Reverb
(

SynthDef(\fxexamplereverb, {arg delaytime=0.01, decaytime=1;

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



y= Synth.tail(a, \fxexamplereverb);



y.free;



