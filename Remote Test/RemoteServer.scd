//remote server
(
s.options.protocol = \tcp; // set to use tcp
s.options.bindAddress = "0.0.0.0"; // allow connections from any address
s.options.maxLogins = 8; // set to correct number of clients
s.reboot;
s.meter;
s.plotTree;
)