
// various config for the experiment

// filename of training/xp session
final String TRAIN_SCRIPT_FILENAME = "train.xml";
final String XP_SCRIPT_FILENAME = "xp.xml";
// corpus for training session
final String TRAIN_RANDOM_CORPUS = "soir95_header_training.csv";
final String TRAIN_SEQUENTIAL_CORPUS = "fairy_training.csv";
// corpus for XP session
final String XP_RANDOM_CORPUS = "soir95_header.csv";
final String XP_SEQUENTIAL_CORPUS = "testaccord_emotion_contexte.csv";

// how many different voices mbrola got for each gender?
public final static int TTS_NB_VOICES=2;
  
// start experiment in fullscreen or not
final boolean START_FULLSCREEN = true;
// in window mode, let resize magic happen
// WARNING: dangerous behavior, will probably crash quickly while resizing
final boolean ENABLE_RESIZE = true;
// default size for window fode
final int WINDOW_X = 1000;
final int WINDOW_Y = 700;
// how often do we compute FPS (in seconds, 0 to disable)
final float FPS_WINDOW = 0;
// set FPS (will induce the running frequency of the whole program -- 0 for default)
final int FPS_LIMIT = 60;

// add timestamp and caller name to each "println"
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
String beatIP = "192.168.5.2";
int beatPort = 11000;

/* config for sending stimulations (see  README for more explainations on code used) */
// true for sending codes to TCP, false will print them to stdout
// TODO: behavior not consitant accross program if false (StageXP will send stim to std out while elsewhere does not)
final boolean enableStimTCP = true; 
String stimIP = "192.168.5.2";
int stimPort = 11001;

/* for debug only -- every option should be "false" for real run */
// if true, prevent HeartManager to send fake beats stims (too verbose for tracking stdout) 
final boolean DEBUG_PREVENT_FAKE_BEATS = false;

