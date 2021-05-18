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

)

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

