//////////////////////////////
// SECTION 1 - DRUM KIT SOUNDS
//////////////////////////////

(
MIDIClient.init;
MIDIClient.sources;           // elenco i controller in entrata e uscita
MIDIClient.destinations;
MIDIIn.connectAll;

//// SERVER SECTION
s.options.protocol = \tcp; // set to use tcp
s.options.bindAddress = "0.0.0.0"; // allow connections from any address
s.options.maxLogins = 2; // set to correct number of clients
s.reboot;
s.meter;
s.plotTree;
////

// 1-Light Kick
SynthDef(\kick, {
    |out = 0, pan = 0, amp = 0.4|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;

    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;

    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// 2-Techno Kick
SynthDef(\technokick, {
	| freq=51.913087197493, amp=0.1, rel=0.28571428571429, out=0, click=0.008, spread=0.1, damp=0.6 gate=1 |
	var sig, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
	// env.ar is really good for this since thie envelopes are so short
	env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -4, bias: 1)); // initial attack
	env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
	aEnv = EnvGen.kr(Env.perc(0.005, rel/1.75, curve: 2)); // amplitude
	wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4));

	vEnv = EnvGen.kr(Env.adsr(rel, rel/2, 1, 0.01, curve: 3),
		gate, doneAction: Done.freeSelf); // for reverb
	// separate signals for extra processing
	low  = SinOsc.ar(freq * env1 * env2);
	high = WhiteNoise.ar() * wEnv * 0.6;
	high = BBandPass.ar(high, 1000, 2);
	dry = Mix.new([low, high]) * aEnv;
	//dry = CrossoverDistortion.ar(dry * 0.3, 0.9, 1);
	// dry = dry * 0.25;
	// equalizer
	dry = BPeakEQ.ar(dry, 5500, db: 10);
	dry = BPeakEQ.ar(dry, 360, db: -12, rq: 2);
	dry = BLowShelf.ar(dry, 300, db: 6).distort;
	// compression
	dry = Compander.ar(dry, dry, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 5);
	// finalize dry signal
	dry = Pan2.ar(dry * aEnv);
	// create reverb signal
	// verb = FreeVerb2.ar(dry[0],dry[1],mix: 1,room: 1, damp: 1).distort * vEnv;
	verb = GVerb.ar(dry, roomsize: 10, revtime: 5,
		damping: damp, drylevel: 0, earlyreflevel: 0.5, taillevel: 1,
		maxroomsize: 100, mul: 1) ;
	// Sum the double stereo output into a single stereo one
	verb = verb.sum;
	// eq
	verb = BLowPass.ar(verb, 400+freq,2);
	// Reduce stereo spread, and balance audio to be level no matter the spread (more or less)
	verbHi = BHiPass.ar(verb, 200);
	verbHi = Balance2.ar(verbHi[0] + (verbHi[1] * spread), // left
		verbHi[1] + (verbHi[0] * spread), level: 0.5 + (1-spread)); // right
	// Keep low frequencies in mono
	verbLo = BLowPass.ar(verb, 200);
	verbLo = Balance2.ar(verbLo[0] + verbLo[1], verbLo[1] + verbLo[0], level: 0.5);
	verb = verbHi + verbLo;
	verb = Compander.ar(verb,verb, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 0.25) * vEnv;
	// finalize signals
	sig = dry + verb;
	sig = Compander.ar(sig,sig, thresh: 0.5,
		slopeBelow: 0.59, slopeAbove: 1,
		clampTime: 0.002, relaxTime: 0.1, mul: 1);
	Out.ar(out, sig);
}).add;

// 3-Gabbber Kick
SynthDef(\gabberkick, {
	| out = 0|
    var snd;
    snd = SinOsc.ar(Env([1000, 69, 60], [0.015, 0.1], \exp).ar * [-0.1, 0, 0.1].midiratio);
    snd = Mix(snd);
    snd = (snd * 10).tanh;
    snd = (snd * 5.1).atan;
    snd = BPeakEQ.ar(snd, XLine.kr(2000, 100, 0.3), 2.0, 8);
    snd = snd + DelayC.ar(snd, 0.01, SinOsc.ar(4).range(0.0, 0.001));
    snd = RLPF.ar(snd, 8000, 0.7);
    snd = snd * Env([0, 1, 0.7, 0.7, 0], [0.001, 0.01, 0.3, 0.02]).ar(2);
    snd = (snd * 0.6).clip(-1, 1);
    Out.ar(out, 0.8*Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;

// 4-Snare
SynthDef(\snare, {
	|out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;

    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// 5-Heavy Snare
SynthDef(\neurosnare, {| out = 0|
    var snd;
    // a percussive click to give it some attack
    snd = LPF.ar(HPF.ar(WhiteNoise.ar, 300), 8000) * Env.linen(0.001, 0.01, 0.001).ar;
    // sine sweep body. very important!
    snd = snd + (SinOsc.ar(Env([400, 196, 160], [0.04, 0.2], \exp).ar) * Env.perc(0.04, 0.2).ar * 6.dbamp).tanh;
    // sound of snare coils rattling
    snd = snd + (HPF.ar(BPeakEQ.ar(WhiteNoise.ar, 4000, 0.5, 3), 300) * Env.perc(0.05, 0.2).delay(0.01).ar(2) * -3.dbamp);
    // another sound sweep to improve the attack, optional
    snd = snd + (SinOsc.ar(XLine.kr(3000, 1500, 0.01)) * Env.perc(0.001, 0.02).ar);
    // distortion helps glue everything together and acts as a compressor
    snd = (snd * 1.4).tanh;
    snd = Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1));
    Out.ar(out, snd);
}).add;


// 6-HiHat
SynthDef(\hihat, {arg out = 0, amp = 0.3, att = 0.01, rel = 0.1, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

// 7-Clap
SynthDef(\clap, {
    |out = 0, amp = 0.5, pan = 0, dur = 1|
    var env1, env2, snd, noise1, noise2;

    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );
    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);
    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(out, Pan2.ar(snd,pan,amp));
}).add;

// 8-Cowbell
SynthDef(\cowbell, {
    | out=0, amp=0.3, gate=1, fund_freq=540, pan=0.0 |
    var sig, env;

    sig = Pulse.ar( fund_freq * [ 1, 1.5085 ], [ 0.565, 0.445 ], [ 0.4, 0.6 ] ).distort;
    env = EnvGen.ar(
            Env(
                [ 0, 0.05, 1, 0.1, 0 ], [ 0.003, 0.002, 0.05, 0.5 ], [2, -4, -4, -4]
            ),
        gate: gate,
        timeScale: [ 1.0, 1.5 ],
        doneAction: 2
        );
    sig = Mix( sig * env );
    sig = BPF.ar( sig, fund_freq * 2, 1.808 );

    Out.ar( out, Pan2.ar( sig, pan, amp ) );
}).add;

// 9-Noise
SynthDef(\blueNoise, {
	arg out = 0, pan = 0, amp = 0.1, gate = 1, att = 0.01, rel = 0.75, curve = -6;

	var noise, a, b, c, d, e, f, g, h, i, env, snd;

	noise = WhiteNoise.ar(1);

	a = HPF.ar(noise, 62,    1/9);
	b = HPF.ar(noise, 125,   1/9);
	c = HPF.ar(noise, 250,   1/9);
	d = HPF.ar(noise, 500,   1/9);
	e = HPF.ar(noise, 1000,  1/9);
	f = HPF.ar(noise, 2000,  1/9);
	g = HPF.ar(noise, 4000,  1/9);
	h = HPF.ar(noise, 8000,  1/9);
	i = HPF.ar(noise, 16000, 1/9);

	env = Env.perc(att, rel, amp, curve).kr(doneAction: 2);

	snd = Mix([a, b, c, d, e, f, g, h, i]) * env;

	Out.ar(out, Pan2.ar(snd, pan));
}
).add;

////////////////////////////////////
///SYNTHETIZER
////////////////////////////////////

// 1-Pluck
SynthDef(\pluck, {arg out = 0, amp = 0.1, freq = 440, decay = 5, coef = 0.1;
	var env, snd;
	env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
	snd = Pluck.ar(
		in: PinkNoise.ar(amp),
		trig: Impulse.kr(0),
		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: coef);
	snd = LeakDC.ar(snd).clip2;

	Out.ar(out, [snd * env,snd * env]);
}).add;

// 2-Synth
SynthDef(\spacey, { arg freq, amp, out = 0;
	var snd, env;
	env = Env.perc(level: amp).kr(2);
	snd = LFSaw.ar(freq: freq, mul: env);
	snd = RLPF.ar(
		in: snd,
		freq: LFNoise1.kr(2).range(500, 20000),
		rq: 0.2
	);
	Out.ar(out, snd);
}).add;

////////////////////////////////////
///PAD
////////////////////////////////////

SynthDef(\arpoctave, {
	arg
	//Standard Controls:
	out = 0, amp = 0.1, freq = 220, pan = 0, gate = 1, att = 0.3, rel = 1, crv = 0,
	//Arp Controls: (mix goes from 0 to 1)
	arprate = 10, arpatt = 0.7, arprel = 0.6, arpmix = 0.35,
	//Chorus and Pitch Bend Controls:
	chorusrate = 0.5, chorusdepth = 0.015, div = 0.25, glide = 0.15,
	//Filter and Delay Controls:
	rq = 0.75, cutoff = 8000, delayt = 0.25, decay = 2, delamp = 0.5;

	var freqk, freqarp, chorus, bend, env, dry, envarp, arp, snd;

//LFOs and Envelopes for Amps, Freqs, and the Filter Cutoff:

	//Envelopes for the arp and dry signals (dry also controls the filter freq):
	env = Env.asr(
		        attackTime: att,
		        releaseTime: rel,
		        curve: crv).ar(gate: gate);
	envarp = Env.asr(
		        attackTime: arpatt,
		        releaseTime: arprel,
		        curve: crv).ar(gate: gate);

	//A chorus-ish sound made by two freq LFOs perfectly out of phase:
	chorus = SinOsc.ar(
		        freq: chorusrate,
		        phase: [0, pi]).range((1 - chorusdepth), (1 + chorusdepth));

	//A bit of portamento at the start of the dry signal:
	bend = Line.ar(start: div, end: 1, dur: glide);

//The Arp and Dry Signals:

	//This makes an aray of all octaves above and below the note being played:
	freqk = ((freq * 2.pow(2/3)).cpsmidi.mod(12) + 16).midicps;
	freqk = freqk * Array.fill(6, {arg i; 2.pow(i)}); // try 2 to 9 instead of 6

	//This randomly jumps between those octaves:
	freqarp = Select.kr(LFNoise0.ar(arprate).range(0, freqk.size), freqk);

	//Arp: Experiment with waveforms!
	arp = LFPulse.ar(freq: freqarp * chorus, mul: envarp);
	arp = Mix.ar(arp);

	//Dry: Experiment with waveforms!
	dry = LFTri.ar(freq: freq * chorus * bend, mul: env);
	dry = Mix.ar(dry);

//Output Stuff:

	//Mixer:
	snd = XFade2.ar(dry, arp, ((arpmix * 2) - 1), amp);

	//Low Pass Filter for mellowness:
	snd = RLPF.ar(
		        in: snd,
		        freq: LinExp.ar(
			                in: env,
			                dstlo: freq,
			                dsthi: cutoff),
                rq: rq);

	//Delay for Space:
	snd = snd + CombN.ar(
		            in: snd,
		            maxdelaytime: delayt,
		            delaytime: delayt,
		            decaytime: decay,
		            mul: delamp);

	//Don't hurt your ears and equipment!
	snd = Limiter.ar(LeakDC.ar(snd));

	DetectSilence.ar(in: snd, doneAction: 2);
	Out.ar(out, Pan2.ar(snd));
}
).add;


SynthDef(\midSideSaw, {
	arg
	// Standard Values
	out = 0, amp = 1, gate = 1, freq = 100, pan = 0, att = 0.25, rel = 3, crv = 0,
	// Filter and Distortion Controls
	filterLo = 100, filterHi = 2000, rq = 0.3, sidePreamp = 2, midPreamp = 1,
	// Chorus and Mid/Side Controls (balance is 0 to 1 and monoSwitch is 0 or 1)
	lfoFreq = 0.1, lfoDepth = 0.015, balance = 0.5, monoSwitch = 0;

	var env, lfo, leftIn, rightIn, mid, side, leftOut, rightOut, snd;

	// Envelope and LFO
	env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		curve: crv).ar(doneAction: 2);

	lfo = SinOsc.ar(
		freq: lfoFreq,
		phase: [0, pi]);
	lfo = lfo.range(1 - lfoDepth, 1 + lfoDepth);

	//Stereo signal with beatings
	leftIn = LFSaw.ar(freq: freq * lfo[0]);
	rightIn = LFSaw.ar(freq: freq * lfo[1]);

	// L/R to M/S conversion
	mid = (leftIn + rightIn)/2;
	side = (leftIn - rightIn)/2;

	// FX on the M/S signal
	mid = RLPF.ar(
		in: mid,
		freq: LinExp.ar(
			in: env,
			srclo: 0, srchi: 1,
			dstlo: filterLo, dsthi: filterHi),
		rq: rq,
		mul: midPreamp);
	mid = mid.softclip/midPreamp.softclip;
	mid = mid * (1 - balance).clip(0, 1) * env;

	side = RLPF.ar(
		in: side,
		freq: LinExp.ar(
			in: env,
			srclo: 0, srchi: 1,
			dstlo: filterHi, dsthi: filterLo),
		rq: rq,
		mul: sidePreamp);
	side = side.softclip/sidePreamp.softclip;
	side = side * balance.clip(0, 1) * env;

	// Output Stuff and Converting Back to L/R
	leftOut = mid + side;
	rightOut = mid - side;
	snd = Select.ar(
		which: monoSwitch,
		array: [
			[leftOut, rightOut],
			Pan2.ar(leftOut, pan)]);
	snd = snd * amp;
	snd = Limiter.ar(snd);

	Out.ar(out, snd);
}
).add;

SynthDef(\feedbackPad1, {
	arg
	// Standard Values
	out = 0, amp = 1, gate = 1, freq = 75, pan = 0,
	// Controls for ampEnv
	att = 2, dec = 1, sus = 1, rel = 4, crv = 0,
	// Controls for fbEnv
	fbStartStop = 0, fbAtt = 3, fbPeak = 0.8, fbDec = 2, fbSus = 0.67, fbRel = 5,
	// Confrols for delEnv
	delStartStop = 0.55, delAtt = 1, delPeak = 0, delDec = 2, delSus = 0.25, delRel = 3.5;

	var snd, fbIn, fbOut, ampEnv, fbEnv, delEnv;

	// Set up the Envelopes
	ampEnv = Env.adsr(
		attackTime: att,
		decayTime: dec,
		sustainLevel: sus,
		releaseTime: rel,
		curve: crv).ar(gate: gate);

	fbEnv = Env.adsr(
		attackTime: fbAtt,
		decayTime: fbDec,
		sustainLevel: fbSus,
		releaseTime: fbRel,
		peakLevel: fbPeak,
		curve: \lin,
		bias: fbStartStop).ar(gate: gate);

	delEnv = Env.adsr(
		attackTime: delAtt,
		decayTime: delDec,
		sustainLevel: delSus,
		releaseTime: delRel,
		peakLevel: delPeak,
		curve: \lin,
		bias: delStartStop).ar(gate: gate);

	// Receive the feedback
	fbIn = LocalIn.ar;

	// The Sound (yup, that's all it is)
	snd = SinOsc.ar(
		freq: freq,
		phase: fbIn * pi);

	// Delay the feedback
	fbOut = DelayC.ar(
		in: snd,
		maxdelaytime: delStartStop.max(delPeak.max(delSus)),
		delaytime: delEnv,
		mul: fbEnv);

	// Send the feedback
	LocalOut.ar(fbOut);

	// Output Stuff
	snd = Mix.ar(snd) * ampEnv * amp;
	snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
}
).add;

SynthDef(\feedbackPad3, {
	arg
	// Standard Values
	out = 0, amp = 0.15, gate = 1, freq = 100, pan = 0,
	// Envelope Controls
	att = 3, dec = 1, sus = 1, rel = 5, crv = 0,
	// Reverb Controls (all go from 0 to 1)
	reverbMix = 0.75, roomSize = 0.9, damp = 0.5,
	// Other Controls (interval is in semitones)
	sampleRate = 20, notes = 6, interval = 7;

	var env, fbIn, snd;

	// Set up the Envelopes
	env = Env.adsr(
		attackTime: att,
		decayTime: dec,
		sustainLevel: sus,
		releaseTime: rel,
		curve: crv).ar(gate: gate);

	// Receive and Sample the feedback
	fbIn = Latch.ar(
		in: (LocalIn.ar + 1)/2,
		trig: Impulse.ar(
			freq: sampleRate));
	fbIn = (fbIn * notes.abs * env).round(1);
	fbIn = (fbIn * interval).midiratio;

	// Make The Sound
	snd = LFTri.ar(
		freq: freq * fbIn,
		mul: env);

	// Feedback the Sound
	LocalOut.ar(snd);

	// Reverb the Sound
	snd = FreeVerb.ar(
		in:  snd,
		mix: reverbMix,
		room: roomSize,
		damp: damp);

	//Filter the Sound
	snd = RHPF.ar(
		in: snd,
		freq: freq,
		rq: 0.5);
	snd = LPF.ar(
		in: snd,
		freq: [62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000],
		mul: 1/9);

	// Output Stuff
	snd = Mix.ar(snd) * amp;
	snd = Limiter.ar(snd);

	DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
}
).add;


SynthDef(\sawSynth, { arg freq = 440, addfreq = 0, amp = 0.1, att = 0.1, rel = 1, lofreq = 1000, hifreq = 3000, pan = 0, out = 0;
    var env, snd;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
	snd = Saw.ar(freq: freq + addfreq * [0.99, 1, 1.001, 1.008], mul: env);

	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
	//snd = LPF.ar(in: snd, freq: );
    snd = Mix.ar(snd);
	snd = Pan2.ar(snd, pan);
    Out.ar(out, snd);
}).add;

SynthDef(\harpsichord2, {
	arg
	//Standard Values
	out = 0, amp = 0.1, freq = 440, pan = 0, rel = 5,
	//Pluck arguments (blend goes from 0 to 1)
	trig = 1, coef = 0.1, blend = 0.6;

	var exciter, root, octave, snd;

        // You can use white noise here, but Pink is more realistic
	exciter = PinkNoise.ar(amp);

	// Fundamental
        root = Pluck.ar(
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 1/freq,
	        delaytime: 1/freq,
	        decaytime: rel,
	        coef: coef,
	        mul: blend
        );

	// Octave Above
	octave = Pluck.ar(
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 1/(2 * freq),
	        delaytime: 1/(2 * freq),
	        decaytime: rel,
	        coef: coef,
	        mul: (1 - blend)
        );

	// Output Stuff
	snd = Mix.ar(root + octave);
	snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
}
).add;

SynthDef(\organDonor,{
	arg out = 0, pan = 0.0, freq = 440, amp = 0.1, gate = 1, att = 0.01, dec = 0.5, sus = 1, rel = 0.5, lforate = 10, lfowidth = 0.01, cutoff = 100, rq = 0.5;

	var vibrato, pulse, filter, env;
	vibrato = SinOsc.ar(lforate, Rand(0, 2.0));
	// up octave, detune by 4 cents
	// 11.96.midiratio = 1.9953843530485
	// up octave and a half, detune up by 10 cents
	// 19.10.midiratio = 3.0139733629359
	freq = freq * [1, 1.9953843530485, 3.0139733629359];
	freq = freq * (1.0 + (lfowidth * vibrato));
	pulse = VarSaw.ar(
		freq: freq,
		iphase: Rand(0.0, 1.0) ! 3,
		width: Rand(0.3, 0.5) ! 3,
		mul: [1.0,0.7,0.3]);
	pulse = Mix(pulse);
	filter = RLPF.ar(pulse, cutoff, rq);
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: 2);
	Out.ar(out, Pan2.ar(filter * env, pan));
}).add;

)

