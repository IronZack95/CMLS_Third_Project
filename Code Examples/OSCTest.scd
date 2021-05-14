s.boot;

(
OSCdef.new(
	\slider, {
		arg msg,time,addr,port;
		[msg, time,addr,port].postln;
	},
	'/1/toggle1'
);
)

NetAddr.langPort;