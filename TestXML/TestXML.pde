
// the different stages of the XP
ArrayList<Stage> stages;
// pointer to current step
int current_stage = -1;

final String XP_SCRIPT_FILENAME = "xp.xml";

// load XML but careful, we don't catch every hiccups
void setup() {
  size(1000, 1000, P2D);

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

      stages.add(new Stage(stage_label));
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
        nbSentences = child.getChild("nbSameValence").getIntContent();
      }
      catch(Exception e) {
        println("Can't find nbSameValence");
      }
      println("nbSameValence: "+ nbSentences);

      // finally, we create our xp stage and add it to list
      Stage stage = new Stage(nbSentences, nbSameValence);
      stages.add(stage);

      // time to look for likert scale and to push them to current stage
      XML likerts[] = child.getChildren("likert");

      println("Found " + likerts.length + " likert scales");

      for (int j = 0; j < likerts.length; j++) {
        XML likert_xml = likerts[j];
        String likert_type = likert_xml.getString("type");
        String likert="liki"+j;
        println("Likert: " + likert, ", likert type: " + likert_type);
        stage.pushLikert(likert, likert_type);
      }
    }
    else {
      println("Error: don't know how to handle stage type \"" + type + "\", ignore.");
    }
  }

  // let's lauch the rocket if we have something
  if (stages.size() > 0) {
    current_stage = 0;
    stages.get(current_stage).activate();
  }
}

void draw() {
  println("Current stage: " + current_stage);
  // be sure to have something to do
  if (current_stage >= 0 && current_stage < stages.size()) {
    Stage stage = stages.get(current_stage);
    stage.update();
    // if stage is done point to next and activate it
    if (!stage.isActive()) {
      current_stage++;
      if (current_stage >= 0 && current_stage < stages.size()) {
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
    background(0);
    fill(255);
    text("The END", 50, 50);
  }
}

// telle current stage a click occurred
void mouseClicked() {
  if (current_stage >= 0 && current_stage < stages.size()) {
    stages.get(current_stage).clicked();
  }
}
