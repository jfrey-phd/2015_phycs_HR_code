
// the different stages of the XP
ArrayList<Stage> stages;
// pointer to current step
int current_step = -1;

final String XP_SCRIPT_FILENAME = "xp.xml";

// load XML but careful, we don't catch every hiccups
void setup() {
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
      stages.add(new Stage("screen!"));
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

      // finally, we create our xp stage
      stages.add(new Stage(nbSentences, nbSameValence));
      
            // time to look for likert scale and to push them to XP
      XML likerts[] = child.getChildren("likerts");
    }
    else {
      println("Error: don't know how to handle stage type \"" + type + "\", ignore.");
    }
  }
}

void draw() {
}
