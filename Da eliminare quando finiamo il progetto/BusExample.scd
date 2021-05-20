(
// the arg direct will control the proportion of direct to processed signal
SynthDef("DecayPink", { arg outBus = 0, effectBus, direct = 0.5;
    var source;
    // Decaying pulses of PinkNoise. We'll add reverb later.
    source = Decay2.ar(Impulse.ar(1, 0.25), 0.01, 0.2, PinkNoise.ar);
    // this will be our main output
    Out.ar(outBus, source * direct);
    // this will be our effects output
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("DecaySin", { arg outBus = 0, effectBus, direct = 0.5;
    var source;
    // Decaying pulses of a modulating sine wave. We'll add reverb later.
    source = Decay2.ar(Impulse.ar(0.3, 0.25), 0.3, 1, SinOsc.ar(SinOsc.kr(0.2, 0, 110, 440)));
    // this will be our main output
    Out.ar(outBus, source * direct);
    // this will be our effects output
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef("Reverb", { arg outBus = 0, inBus;
    var input;
    input = In.ar(inBus, 1);

    // a low-rent reverb
    // aNumber.do will evaluate its function argument a corresponding number of times
    // {}.dup(n) will evaluate the function n times, and return an Array of the results
    // The default for n is 2, so this makes a stereo reverb
    16.do({ input = AllpassC.ar(input, 0.04, { Rand(0.001,0.04) }.dup, 3)});

    Out.ar(outBus, input);
}).add;

b = Bus.audio(s,1); // this will be our effects bus
)

(
s.boot;

~myBus = Bus.audio(s, 2);
~effect = Bus.audio(s, 2);

// Turn on the reverb: read from myBus (source sound)
r = {Out.ar(0, FreeVerb.ar(In.ar(~myBus, 2), mix: 0.5, room: 0.9, mul: 0.4))}.play;

// Feed the tone into ~myBus
b = {Out.ar(~myBus, SinOsc.ar([800, 880], mul: LFPulse.ar(2)))}.play;
~myBus.scope
e = {Out.ar(0, SinOsc.ar([800, 880], mul: LFPulse.ar(2)))}.play;
Mix.([]);
)
r.free;
e.free;
b.free;


(
x = Synth.new("Reverb", [\inBus, b]);
y = Synth.before(x, "DecayPink", [\effectBus, b]);
z = Synth.before(x, "DecaySin", [\effectBus, b, \outBus, 0]);
)

// Change the balance of wet to dry
(
y.set(\direct, 1); // only direct PinkNoise
z.set(\direct, 1); // only direct Sine wave
)
(
y.set(\direct, 0); // only reverberated PinkNoise
z.set(\direct, 0); // only reverberated Sine wave
)
x.free; y.free; z.free; b.free;