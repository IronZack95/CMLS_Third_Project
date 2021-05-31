(
SynthDef("filteredDust", {arg outBus=2 ;
    Out.ar(outBus,Mix.arFill(10, { Resonz.ar(Dust.ar(0.2, 50), Rand(200, 3200), 0.003) })
    )
}).add;
​
SynthDef("preDelay", {arg outBus=0 , inBus = 2;
    ReplaceOut.ar(outBus,DelayN.ar(In.ar(inBus, 1), 0.048, 0.048)
    )
}).add;
​
SynthDef("combs", {arg outBus=6 , inBus = 4;
    ReplaceOut.ar(outBus,Mix.arFill(7, { CombL.ar(In.ar(inBus, 1), 0.1, LFNoise1.kr(Rand(0, 0.1), 0.04, 0.05), 15)})
    )
}).add;
​
SynthDef("allpass", { arg outBus= 0 , inBus = 6, gain = 0.2;
    var source;
    source = In.ar(inBus, 1);
    4.do({ source = AllpassN.ar(source, 0.050, [Rand(0, 0.05), Rand(0, 0.05)], 1) });
    ReplaceOut.ar(outBus,source * gain)
}).add;
​
SynthDef("theMixer", { arg outBus = 0, effect  = 8, dust = 2 , gain = 1;
    ReplaceOut.ar( outBus,Mix.ar([In.ar(dust, 1), In.ar(effect, 2)]) * gain
    )
}).add;
)

(
~voice =  Synth.new(\wet, [\inBus, ~drum]);
Synth.tail(r, "filteredDust");
Synth.tail(r, "preDelay");
Synth.tail(r, "combs");
Synth.tail(r, "allpass");
Synth.tail(r, "theMixer");
)
r.freeAll
