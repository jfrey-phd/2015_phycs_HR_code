
// various config for the experiment

// add caller name to each "println"
boolean printStack = true;
// also write stdout to file on disk?
boolean printToFile = true;
// basename (no extenntion) of the file for "piping" stdout (relative to sketch folder)
String stdoutFileBasename = "../recordings/stdout";

// conf for CSV
boolean exportCSV = true;
String CSVFileBasename = "../recordings/subject";

/* config for beat detection */
// true for reading beats from TCP, false for a default value
final boolean enableBeatTCP = true; 
String beatIP = "127.0.0.1";
int beatPort = 11000;

/* config for sending stimulations (see  README for more explainations on code used) */
// true for sending codes to TCP, false will print them to stdout
// TODO: behavior not consitant accross program if false (StageXP will send stim to std out while elsewhere does not)
final boolean enableStimTCP = true; 
String stimIP = "127.0.0.1";
int stimPort = 11001;

