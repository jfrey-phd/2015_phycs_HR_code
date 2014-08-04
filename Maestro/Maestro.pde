
// coordinates all the different modules

// where the sentences comes from, random type
Corpus corpus_random;
// pointer to the currently used corpus
// (we load only once the corpus because we follow a sequential order or avoid duplicates)
Corpus corpus_current;
// TTS engine
AgentSpeak tts;
// which file gives info about available body parts
final String CSV_BODY_FILENAME = "body_parts.csv";

// the different stages of the XP
ArrayList<Stage> stages;
// pointer to current step
int current_stage = -1;
final String XP_SCRIPT_FILENAME = "xp.xml";

int WINDOW_X = 1000;
int WINDOW_Y = 1000;


void setup() {
  // init logs
  Diary.applet = this;
  // using 2D backend as we won't venture in 3D realm
  size(WINDOW_X, WINDOW_Y, P2D);
  smooth();
  // we don't choose our font but we want smooth text -- should not work with P2P from doc??
  textMode(SHAPE);

  // init for body parts randomness -- got headers, fields separated by tabs
  Table body_parts = loadTable(CSV_BODY_FILENAME, "header, tsv");
  println("Loaded " + CSV_BODY_FILENAME + ", nb rows: " + body_parts.getRowCount());
  Body.setTableParts(body_parts);

  // init for TTS
  tts = new AgentSpeak();

  // load sententes
  Corpus corpus_random = new Corpus();
  corpus_current = corpus_random;

  // load stages
  loadStages();
}

// load stages for XP
void loadStages() {

  stages = new ArrayList<Stage>();
  // load file
  println("Loading script file " + XP_SCRIPT_FILENAME);
  XML xp_script = loadXML(XP_SCRIPT_FILENAME);
  // get stages and loop to populate them
  XML[] xml_stages = xp_script.getChildren("stage");
  println("Found " + xml_stages.length + " stages");


  for (int i=0; i<xml_stages.length; i++) {
    // check for type
    XML child = xml_stages[i];
    String type = child.getString("type");
    // calling different constructor depending of them
    if (type.equals("title")) {
      println("Create type screen");
      // get label

      // same for how many of the same valence in a row we should use
      String stage_label = "title screen";
      try {
        stage_label = child.getChild("label").getContent();
      }
      catch(Exception e) {
        println("Can't find label");
      }
      println("label: "+ stage_label);

      stages.add(new StageTitle(stage_label));
    }
    else if (type.equals("xp")) {
      println("Create type XP");

      // tries to catch the number of sentences per agent
      int nbSentences = 0;
      try {
        nbSentences = child.getChild("nbSentences").getIntContent();
      }
      catch(Exception e) {
        println("Can't find nbSentences");
      }
      println("nbSentences: "+ nbSentences);

      // same for how many of the same valence in a row we should use
      int nbSameValence = 0;
      try {
        nbSameValence = child.getChild("nbSameValence").getIntContent();
      }
      catch(Exception e) {
        println("Can't find nbSameValence");
      }
      println("nbSameValence: "+ nbSameValence);

      // finally, we create our xp stage and add it to list
      StageXP stage = new StageXP(tts, nbSentences, nbSameValence);
      stages.add(stage);

      // time to look for likert scale and to push them to current stage
      XML likerts[] = child.getChildren("likert");

      println("Found " + likerts.length + " likert scales");

      for (int j = 0; j < likerts.length; j++) {
        XML likert_xml = likerts[j];
        String likert_type = likert_xml.getString("type");

        // not nice, but will try/cath to grab at once question + nb answers + labels
        String question = "likert question";
        int nbButtons = 7;
        String from = "from";
        String neutral = "neutral";
        String to = "to";

        try {
          question = likert_xml.getChild("question").getContent();
          nbButtons = likert_xml.getChild("nb").getIntContent();
          from = likert_xml.getChild("from").getContent();
          neutral = likert_xml.getChild("middle").getContent();
          to = likert_xml.getChild("to").getContent();
        }
        catch(Exception e) {
          println("Can't find some of the likret parameters...");
        }

        println("Likert: " + question, ", likert type: " + likert_type);
        stage.pushLikert(likert_type, question, nbButtons, from, neutral, to);
      }
    }
    else {
      println("Error: don't know how to handle stage type \"" + type + "\", set default one.");
    }
  }

  // let's lauch the rocket if we have something
  if (stages.size() > 0) {
    current_stage = 0;
    println("Launch stage: " + current_stage);
    stages.get(current_stage).activate();
  }
}

void draw() {
  //println("Current stage: " + current_stage);
  // be sure to have something to do
  if (current_stage >= 0 && current_stage < stages.size()) {
    Stage stage = stages.get(current_stage);
    stage.update();
    // if stage is done point to next and activate it
    if (!stage.isActive()) {
      current_stage++;
      if (current_stage >= 0 && current_stage < stages.size()) {
        println("Launch stage: " + current_stage);
        stages.get(current_stage).activate();
      }
    }
    // otherwise it's ok to draw it
    else {
      stage.draw();
    }
  }
  // all done ?
  else {
    //println("No more stages");
    background(0);
    fill(255);
    text("The END", 50, 50);
  }
}

// trigger different action for debug
void keyPressed() {
  //  // debug animation
  //  if (key == 'b') {
  //    agent.eyes.animate();
  //  }
  //  else if (key == 'm') {
  //    agent.mouth.animate();
  //  }
  //  else if (key == 'h') {
  //    agent.heart.animate();
  //  }

  // debug TTS
  if (key == 's') {
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
  //  else if (key == 'r') {
  //    createAgent();
  //  }
}

// tell current stage a click occurred
void mouseClicked() {
  if (current_stage >= 0 && current_stage < stages.size()) {
    stages.get(current_stage).clicked();
  }
}

// tell current stage a press occurred
void mousePressed() {
  if (current_stage >= 0 && current_stage < stages.size()) {
    stages.get(current_stage).pressed();
  }
}

// tell current stage a release occurred
void mouseReleased() {
  if (current_stage >= 0 && current_stage < stages.size()) {
    stages.get(current_stage).released();
  }
}


// wrapper for tts.speak in order to use thread()
// FIXME: also called by Stage...
void speak() {
  tts.speak();
}
