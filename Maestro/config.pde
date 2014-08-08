
// various config for the experiment

// add caller name to each "println"
boolean printStack = false;

/* config for beat detection */
// true for reading beats from TCP, false for a default value
final boolean enableBeatTCP = true; 
String beatIP = "127.0.0.1";
int beatPort = 11000;

/* config for sending stimulations (see  README for more explainations on code used) */
// true for reading beats from TCP, false for a default value
final boolean enableStimtTCP = true; 
String stimIP = "127.0.0.1";
int stimPort = 11001;

