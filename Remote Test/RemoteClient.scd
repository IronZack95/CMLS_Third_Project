(
s.options.maxLogins = 8;
// creo l'oggetto remote server

r = Server(
    \remote,
    // example NetAddr of the machine that runs scsynth on standard port
    //NetAddr("192.168.1.8", 57110),
	NetAddr("ironzckserver.ddns.net", 57110),
    s.options,        // make sure all remote servers use the same options
    1                // and when desired, set fixed client by hand
);
/*
r = Server(
    \remote,
    // example NetAddr of the machine that runs scsynth on standard port
    //NetAddr("192.168.1.8", 57110),
	NetAddr("miosupercollider.ddns.net", 57110),
    s.options,        // make sure all remote servers use the same options
    8                // and when desired, set fixed client by hand
);
*/
r.addr.connect;
r.startAliveThread( 0 );
r.doWhenBooted({ "remote tcp server started".postln; r.notify; r.initTree });

// imposto il server Remoto come quello di defoult
Server.default = r;

//plotto informazioni sul server
r.clientID;
r.plotTree;
r.defaultGroupID;     // 268435457
'number of allowed servers'.postln();
r.options.maxLogins    // 8
)

r.addr.disconnect;

// Synth
x = Synth(\default, nil);
x.release;

x = { Dust.ar(10!2).lag(0.002) }.play(r);
x.release(2);

Pbind(\degree, Pseq((0..7).mirror), \dur, 0.15, \server, r).play;

(dur: inf).play;
s.freeAll;

// JITLib nodeproxies
Ndef(\x, { Dust.ar(10 ! 2) });
Ndef(\x).play;
Ndef(\x).filter(10, { |in| Ringz.ar(in, [600, 800], 0.03) }).play;
Ndef(\x).end(3);