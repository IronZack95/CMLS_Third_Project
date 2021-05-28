///////////////////
// Serial section
///////////////////
~interface.stop

~port = SerialPort.new("COM3", 9600);
(
~charArray = [ ];
~getValues = Routine.new({
	var ascii;
	var address = 0; var last_address = 0;
	var data = 0; var last_data = 0;
	{
		ascii = ~port.read.asAscii; // read è una funzione Blocking
		if(ascii.isDecDigit){~charArray = ~charArray.add(ascii)};
		if(ascii == $a){
			~val= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
			data = ~val;
			'd: '.post();
			~val.postln();
		};
		if(ascii == $d){
			~val= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
			address = ~val;
			'a: '.post();
			~val.postln();
		};
		// LOGICA
		if(address != last_address || data != last_data){
			last_data = data;
			last_address = address;
			if(address == 100){
				if( data < 100,{
					~sensor.set(data/100)})}};
	}.loop;
}).play;
)
~sensor.get({arg value; value.postln();});

/*
(
x = SynthDef("tutorial-map", { arg freq1 = 440, freq2 = 440;
    Out.ar(0, SinOsc.ar([freq1, freq2], 0, 0.1));
}).play(s);
)
*/
// CLOSE CONNECTIONS
(
~getValues.stop;
~port.close;
)