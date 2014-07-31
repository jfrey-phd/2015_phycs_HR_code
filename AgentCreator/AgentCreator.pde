
Agent agent;

void setup() {
  // using 2D backend as we won't venture in 3D realm
  size(1000, 1000, P2D);
  smooth();
  // init for drawing / BPM
  agent = new Agent();
  // init for TTS
  AgentSpeak_setup();
  // load sententes
  Corpus_setup();
}

void draw() {
  // reset display
  background(255);
  // draw every part, deals with blinking also
  agent.draw();
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
    agentSetText(mes);
    thread("speak");
  }
  // speak sad
  else if (key == '1') {
    agentSetText(Corpus_drawText(-1));
    thread("speak");
  }
  // speak neutral
  else if (key == '2') {
    agentSetText(Corpus_drawText(0));
    thread("speak");
  }
  // speak happy
  else if (key == '3') {
    agentSetText(Corpus_drawText(1));
    thread("speak");
  }
}

