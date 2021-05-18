s.boot;

(
OSCdef.new(
	\slider1, {
		arg msg,time,addr,port;
		[msg, time,addr,port].postln;
	},
	'/1/fader1'
);

OSCdef.new(
	\slider2, {
		arg msg,time,addr,port;
		[msg, time,addr,port].postln;
	},
	'/1/fader2'
);

OSCdef.new(
	\slider3, {
		arg msg,time,addr,port;
		[msg, time,addr,port].postln;
	},
	'/1/fader3'
);
)

NetAddr.langPort;
NetAddr.localAddr;