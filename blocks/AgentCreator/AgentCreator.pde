
// the current showed agent
Agent agent;
// where the sentences comes from, random type
Corpus corpus_random;
// pointer to the currently used corpus
// (we load only once the corpus because we follow a sequential order or avoid duplicates)
Corpus corpus_current;
// TTS engine
AgentSpeak tts;

int WINDOW_X = 1000;
int WINDOW_Y = 1000;

final String CSV_body_filename = "body_parts.csv";

void setup() {
  // init logs
  Diary.applet = this;
  // using 2D backend as we won't venture in 3D realm
  size(WINDOW_X, WINDOW_Y, P2D);
  smooth();

  // init for body parts randomness -- got headers, fields separated by tabs
  Table body_parts = loadTable(CSV_body_filename, "header, tsv");
  println("Loaded " + CSV_body_filename + ", nb rows: " + body_parts.getRowCount());
  Body.setTableParts(body_parts);

  // init for TTS
  tts = new AgentSpeak();

  // init agent
  createAgent();

  // load sententes
  Corpus corpus_random = new Corpus();
  corpus_current = corpus_random;
}

// will create/reset agent
void createAgent() {
  println("(re)creating agent");
  // init for drawing / BPM
  agent = new Agent();
  // a bit to big by default
  agent.getPShape().scale(0.8);
  // point to TTS
  agent.setTTS(tts);
}

void draw() {
  // reset display
  background(255);
  // update every part, deals all animations
  agent.update();
  // draw (somewhat) in the middle
  shape(agent.getPShape(), 100, 100);
}

// trigger different action for debug
void keyPressed() {
  // debug animation
  if (key == 'b') {
    agent.eyes.animate();
  }
  else if (key == 'm') {
    agent.mouth.animate();
  }
  else if (key == 'h') {
    agent.heart.animate();
  }

  // debug TTS
  else if (key == 's') {
    String mes = "Bonjour tout le monde et bonjour et bonjour !";
    tts.setText(mes);
    thread("speak");
  }
  // speak sad
  else if (key == '1') {
    tts.setText(corpus_current.drawText(-1));
    thread("speak");
  }
  // speak neutral
  else if (key == '2') {
    tts.setText(corpus_current.drawText(0));
    thread("speak");
  }
  // speak happy
  else if (key == '3') {
    tts.setText(corpus_current.drawText(1));
    thread("speak");
  }

  // debug for agent
  else if (key == 'r') {
    createAgent();
  }
}

// wrapper for tts.speak in order to use thread()
void speak() {
  tts.speak();
}
