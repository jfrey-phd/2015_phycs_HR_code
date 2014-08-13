
// coordinates all the different modules

// FIXME: prone to crash if resized (?? even with simple content)

import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;

// where the sentences comes from, random type
Corpus corpus_random;
// pointer to the currently used corpus
// (we load only once the corpus because we follow a sequential order or avoid duplicates)
Corpus corpus_current;
// TTS engine
AgentSpeak tts;
// Beat reader from TCP
HeartManager hrMan;
// Write stimulation -- could be to TCP with TCPClientWrite if enableStimtTCP, or only to stdout otherwise
StimManager stimMan;

// how many loops we had last time we checked FPS?
long frameTick = 0;
// last time we've checked FPS
long FPSTick = 0;

// which file gives info about available body parts
final String CSV_BODY_FILENAME = "body_parts.csv";

// the different stages of the XP
ArrayList<Stage> stages;
// pointer to current step
int current_stage = -1;
final String XP_SCRIPT_FILENAME = "xp.xml";

// we'll send the last stimulation once
boolean endXPSent = false;

int WINDOW_X = 1000;
int WINDOW_Y = 1000;


void setup() {
  // init logs
  Diary.setup(this, printStack, printToFile, sketchPath("")+stdoutFileBasename, exportCSV, sketchPath("")+CSVFileBasename);
  // using 2D backend as we won't venture in 3D realm
  size(WINDOW_X, WINDOW_Y, P2D);
  // enable resize
  if (frame != null) {
    frame.setResizable(true);
    // FIXME: enter weird realm, adding callback for resize event
    frame.addComponentListener(new ComponentAdapter() {
      public void componentResized(ComponentEvent e) {
        if (e.getSource()==frame) {
          resized();
        }
      }
    }
    );
  }
  // tries to avoid aliasing
  smooth();
  // we don't choose our font but we want smooth text -- should not work with P2P from doc??
  textMode(SHAPE);

  // limit FPS in case we have a slow machine (or too greedy programs)
  if (FPS_LIMIT > 0) {
    frameRate(FPS_LIMIT);
  }

  // it writing TCP, but it'll be up to StimManager to handle that, only need Trigger interface that the other component could directly give their codes
  stimMan = new StimManager();

  // will init TCP reading if option is set, otherwise serve as a relay for fake beats  with 
  hrMan = new HeartManager(stimMan, enableBeatTCP);

  // init for body parts randomness -- got headers, fields separated by tabs
  Table body_parts = loadTable(CSV_BODY_FILENAME, "header, tsv");
  println("Loaded " + CSV_BODY_FILENAME + ", nb rows: " + body_parts.getRowCount());
  Body.setTableParts(body_parts);

  // start up Ess for AgentSpeak and heartbeat
  Ess.start(this);
  // init for TTS
  tts = new AgentSpeak();

  // load sententes
  Corpus corpus_random = new Corpus();
  corpus_current = corpus_random;

  // xp starts (loadStages launches a stage, so for clarity have to put it before)
  stimMan.sendMes("OVTK_StimulationId_ExperimentStart");

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

      stages.add(new StageTitle(stimMan, stage_label));
    } else if (type.equals("xp")) {
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
      StageXP stage = new StageXP(stimMan, hrMan, tts, nbSentences, nbSameValence);
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

      // last but not least: check for agents
      XML agents[] = child.getChildren("agent");
      println("Found " + agents.length + " agents");

      for (int j = 0; j < agents.length; j++) {
        XML agent_xml = agents[j];
        // try to find HR tag
        String HRType = "";
        try {
          HRType = agent_xml.getChild("HR").getContent();
          println("Found HR="+HRType);
        }
        catch(Exception e) {
          println("Can't find HR condition");
        }

        // try to find how may times we show it -- by default once
        int timesAgent = 1;
        try {
          timesAgent = agent_xml.getChild("nb").getIntContent();
          println("Found nb times agent="+timesAgent);
        }
        catch(Exception e) {
          println("Can't find nb times agent condition");
        }

        // push to stage
        stage.pushAgent(HRType, timesAgent);
      }
    } else {
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

// count loops number and print FPS when needed
void monitorFPS () {
  // timestamp NOW!
  long now = millis();
  // reached time to compute new FPS
  if (now - FPSTick - FPS_WINDOW * 1000 > 0 
    // avoid division by 0
  && now != FPSTick) {
    float fps = (frameCount - frameTick) / ((now - FPSTick) / 1000);
    println("FPS over " + FPS_WINDOW + "s: " + fps + " (" + frameRate + " reported, " + FPS_LIMIT + " set)");
    // reset counters
    frameTick = frameCount;
    FPSTick = now;
  }
}

// draw... and update recursively a lot of stuf
void draw() {
  // update Beats reading from TCP if option is set
  if (enableBeatTCP) {
    hrMan.update();
  }

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
    // we don't want send an infinite number of end signal
    if (!endXPSent) {
      stimMan.sendMes("OVTK_StimulationId_ExperimentStop");
      endXPSent = true;
    }
    //println("No more stages");
    background(0);
    fill(255);
    text("The END", 50, 50);
  }

  // let's have a look at how FPS are going if asked to
  if (FPS_WINDOW > 0) {
    monitorFPS();
  }

  // messages may need to be pushed to TCP
  // TODO: more handy to push at the end of draw, but if we have cleanup to do at the end of XP, don't forget to move up
  stimMan.update();
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

// close ESS on exit
// TODO: cleanup other things...
// FIXME: should use handler...
public void dispose () {
  println("Exiting...");
  // beyond this point, no println should be called (will not be written to disk if flag get)
  Diary.dispose();
  // FIXME: this one seems to freeze regurarely app :\
  Ess.stop();
}

// override println() in order to get Diary facilitation (ie calling class if flag set)
// WARNING: as long as Diary.applet is not set, will discard every println
static void println(String str) {
  // Set stack depth for caller name
  // 0: getStack
  // 1: Diary.println(String text, int stackDepth)
  // 2: this function
  // 3: what we want to know
  Diary.println(str, 3);
}

// called when window is resized
void resized() {
  println("Resizing.");
  // update current stage layout
  if (current_stage >= 0 && current_stage < stages.size()) {
    Stage stage = stages.get(current_stage);
    if (stage.isActive()) {
      stage.fitScreen();
    }
  }
}

