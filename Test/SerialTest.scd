(
p = SerialPort(
    "COM3",    //edit to match your port. SerialPort.listDevices
    baudrate: 9600,    //check that baudrate is the same as in arduino sketch
    crtscts: true);
)

//read 10bit serial data sent from Arduino's Serial.println
(
r= Routine({
    var byte, str, res;
    99999.do{|i|
        if(p.read==24, {
            str = "";
            while({byte = p.read; byte !=13 }, {
                str= str++byte.asAscii;
            });
            res= str.asInteger;
            ("read value:"+res).postln;
        });
    };
}).play;
)

r.stop;
p.close;

// --------------------FUNZIONA------------------------

~port = SerialPort.new("COM3", 9600);
(
~charArray = [ ];
~getValues = Routine.new({
	var ascii;
	{
		ascii = ~port.read.asAscii; // read è una funzione Blocking
		if(ascii.isDecDigit){~charArray = ~charArray.add(ascii)};
		if(ascii == $a){
			~val= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
			'a: '.post();
			~val.postln();
		};
		if(ascii == $d){
			~val= ~charArray.collect(_.digit).convertDigits;
			~charArray = [ ];
			'd: '.post();
			~val.postln();
		};
	}.loop;
}).play;
)
~getValues.stop;
~port.close;



// altro esempio -----------
SerialPort.devices;
~port = SerialPort.new("COM3", 9600);

(
x= [ ];
30.do{x = x.add(~port.read)};
x = x.collect(_.asAscii);

)

~port.close;