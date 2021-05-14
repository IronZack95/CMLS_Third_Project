(
 SynthDef(\s1,
	{
		arg freq, amp, pan;
		var sig;
		sig = SinOsc.ar(freq,mul:amp);

		Out.ar(0, Pan2.ar(sig,pan));
 }).add;
)

// Create a network with the listener
// SuperCollider will listen to msgs at defined port and address
NetAddr("127.0.0.1",57120);

(
var synth1,synth2;
synth1 = Synth(\s1,[\freq, 440,\amp,0.5,\pan,-1]);
synth2 = Synth(\s1,[\freq, 880,\amp,0.5,\pan,1]);

// create a new and enabled OSCdef
// the first argument is the key at which to store this OSCDef in the global collection
// the second argument is a function that will respond to the incoming message; when evaluated it will have the arguments msg, time, addr and recvPort; we are going to use only the message argument which is an Array in the form of [OSC address, arg1, arg2,...]
// the third argument is the path of the OSC address (must begin with a / )

OSCdef('OSCreceiver',
	{
		arg msg;

		x = msg[1];
		y = msg[2];
		// x corresponds to panning, so it has to be between -1 and 1 (now is between 0 and 1)
		x = (x-0.5)/0.5;

		postln("x: "+x+" - y: "+y);
		synth1.set(\amp,y,\pan,x);
		synth2.set(\amp,1-y,\pan,1-x);

	},
	"/pos");
)


//__________________________________
//A buffer is most often used to hold sampled audio, such as a soundfile loaded into memory, but can be used to hold other types of data as well. Technically speaking, a buffer on the server is a globally available, multichannel array of 32-bit floating-point numbers. It also has an associated sample rate, represented in Hertz as a 64-bit float.
// the method read on buffer allocate a buffer and immediately read a soundfile into it. This method sends a query message as a completion message so that the Buffer's instance variables will be updated automatically.

~song1 = Buffer.read(s,"/Users/clara/Desktop/Lezioni/CMLS/Labs/Lab 9 - Music Interaction/ex2_MixSquare/test.wav");

~song2 = Buffer.read(s,"/Users/clara/Desktop/Lezioni/CMLS/Labs/Lab 9 - Music Interaction/ex2_MixSquare/test2.wav");

(
 SynthDef(\song,
	{
		arg bufnum = 0, amp, pan;    // Number of the buffer to play
		var sig;
		// plays back a sample resident in memory
		// PlayBuf(numchannels, buffer number, rate, doneAction)
		// doneAction=0 means do nothing when the UGen is finished
		// rate = 1 means use the same sample rate of the server
		sig = PlayBuf.ar(1, bufnum, 1, doneAction:0);
		Out.ar(0, Pan2.ar(sig*amp, pan));

 }).add;
)

NetAddr("127.0.0.1",57120);

(
var synth1,synth2;
synth1 = Synth(\song,[\amp,0.5,\pan,-1,\bufnum, ~song1.bufnum]);
synth2 = Synth(\song,[\amp,0.5,\pan,1,\bufnum, ~song2.bufnum]);


OSCdef('OSCreceiver',
	{
		arg msg;
		x = msg[1];
		y = msg[2];

		x = (x-0.5)/0.5;

		postln("x: "+x+" - y: "+y);

		synth1.set(\amp,y / 2 ,\pan,x);
		synth2.set(\amp, (1-y) / 2,\pan,1-x);

	},
	"/pos");
)

