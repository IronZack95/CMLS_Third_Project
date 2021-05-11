// vari suoni drumkit

(
// 1-Kick
SynthDef(\kick, {
    |out = 0, pan = 0, amp = 0.3|
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

// 2-Snare
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

// 3-Hihat
SynthDef(\hihat, {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

// 4-Clap
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

// 5-Pluck
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

	Out.ar(out, snd * env);
}).add;

// 6-Gong Percussion
SynthDef(\dong, {
	arg out= 0, pan= 0, freq= 400, amp= 0.1, dur= 2, t_trig=1;
	var amps= [1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33];
	var durs= [1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];
	var frqs= [0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
	var dets= [0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];

	var src= Mix.fill(11, {
		arg i;
		var env = EnvGen.ar(Env.perc(0.005, dur*durs[i], amps[i], -4.5), t_trig);
		SinOsc.ar(freq*frqs[i]+dets[i], 0, amp*env);
	});

	Out.ar(out, Pan2.ar(src, pan));
}).add;

// 7-Alien Sound
SynthDef(\alien, { arg freq = 500, amp = 4;
    var env, snd;

    env = Env.perc(level: amp).kr(2);
    snd = BPF.ar(
        in: LFPulse.ar(
            freq: LFNoise0.kr([8,19]).range(freq, freq*2),
            mul: env),
        freq: MouseY.kr(500, 2500),
        rq: 0.1
    );

    Out.ar(0, snd);
}).add;

// 8-Keyboard Synth
SynthDef(\keyboard, {
    |
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
    // all of these range from 0 to 1
    modIndex = 0.2, mix = 0.2, lfoSpeed = 4.8, lfoDepth = 0.1
    |
    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin)) ;
    env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin)) ;
    env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin)) ;
    env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin)) ;

    osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex* env4 ;
    osc3 = SinOsc.ar(freq, osc4) * env3;
    osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2;
    osc1 = SinOsc.ar(freq, osc2) * env1;

	snd = (osc3 * (1 - mix)) + (osc1 * mix);
    snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);
    snd = snd * EnvGen.ar(Env.asr(0, 1, 0.1), gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
}).add;
)

///////////////////

// solo per sentire i suoni della DrumKit in sequenza

(
var base;

base = Pbind(\amp, 0.3);

Ppar([
    Pbindf(
        base,
		\instrument, Pseq([\keyboard, \alien, \pluck, \dong, \kick, \snare], inf),
        \dur, Pseq([4, 3, 3, 2, 4], inf)
    ),
    Pbindf(
        base,
		\instrument, Pseq([Pn(\hihat, 16), Pn(\clap, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    )
]).play(TempoClock(2.3 * 4));
)