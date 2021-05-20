s.boot;

(
fork {
    p = ParGroup.new;
    loop {
        (
            degree: rrand(0.0, 12.0).round(1/4),
            group: p,
            db: rrand(-30, -25),
            pan: rrand(-1.0, 1.0)
        ).play;
        0.2.wait;
    }
}:
)


//////
(
SynthDef("help-Group-moto-rev", { arg out=0,freq=100,ffreq=120;
    var x;
    x = RLPF.ar(LFPulse.ar(SinOsc.kr(0.2, 0, 10, freq), [0,0.1], 0.1),
        ffreq, 0.1).clip2(0.4);
    Out.ar(out, x);
}).add;
​
​
SynthDef("help-Group-wah", { arg out, rate = 1.5, cfreq = 1400, mfreq = 1200, rq=0.1;
    var zin, zout, q;
​
    zin = In.ar(out, 2);
    cfreq = Lag3.kr(cfreq, 0.1);
    mfreq = Lag3.kr(mfreq, 0.1);
    q   = Ramp.kr(rq, 0.1);
    zout = RLPF.ar(zin, LFNoise1.kr(rate, mfreq, cfreq), q, 10).distort
        * 0.15;
​
    // replace the incoming bus with the effected version
    ReplaceOut.ar( out , zout );
​
}).add;
)
​
g = Group.new;
​
(
l = Array.fill(3,{
    // random freq for each synth, added to g at the head
    Synth("help-Group-moto-rev",["out",0,"freq",rrand(10,120)],g,\addToHead);
});
)
​
// set all controls that match "ffreq" in all nodes in g to 90
g.set("ffreq",100);
​
g.set("freq",85);
​
// since we stored the Synths in an Array, we can also control them individually
(
r = Routine({
    inf.do({
        l.do({ arg node;
            node.set("freq",rrand(10,120));
            1.0.wait;
        });
    })
});
​
r.play;
)
​
// g is in a group too. Since we didn't specify it's the default group (ID 1) of the default Server
g.group.inspect;
​
// asking a wah to go order-of-execution after g, in the same group as g.
x = Synth.after(g,"help-Group-wah",["out",0]);
​
x.set("cfreq",1400);
// now dump my tree to confirm
g.dumpTree;
​
x.free;
​
// free all nodes in g, but not g itself
g.freeAll;
​
// don't forget the Routine is still running...
r.stop;
​
// oh, and set l to nil so the Synths and Array can be garbage collected
l = nil;
​
// and i'm still on the server, its just my children that were freed
g.query;
​
// don't need the individual synth objects this time
(
3.do({
    // random freq for each synth, added to g at the head
    Synth("help-Group-moto-rev",["out",0,"freq",rrand(10,1200)],g,\addToHead);
});
)
​
// now query my tree and post a graph of it (duplicates dumpTree)
// msg format is ['/g_querytree.reply', node1-ID, numChildren, defName, child1-ID, numChildren, ...]
(
g.queryTree({|msg|
   var i = 1, tabs = 0, dumpFunc;
   ("NODE TREE Group" + msg[1]).postln;
   if(msg[2] > 0, {
       dumpFunc = {|numChildren|
           tabs = tabs + 1;
           numChildren.do({
               i = i + 3;
               tabs.do({ "   ".post });
               msg[i].post;
               (" " ++ msg[i + 2]).postln;
               if(msg[i + 1] > 0, { dumpFunc.value(msg[i + 1]) });
           });
           tabs = tabs - 1;
       };
       dumpFunc.value(msg[2]);
   });
});
)
​
// kill me and my children
g.free;
​
// see, I'm gone
g.query;
