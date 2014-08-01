
// handle info about what's currently going on during the XP, will disable by itself when job's done
// this is the main place where draw occurs...
// TODO: could do better with inheritance

class Stage {
  // 0: title
  // 1: xp
  private int type = -1;

  // will wait signal before going to work and will disable by itself when job's done
  private boolean active = false;
  // a timer since activation
  private int start_time = 0;
  // how many time in ms should this stage be active (for title)
  private final int SHOW_TIME = 2000;

  // array list of (sort of) likert scale for sentences
  ArrayList<String> likertsSentence; 
  // array list of (sort of) likert scale for agent
  ArrayList<String> likertsAgent; 

  // for screen
  private String label = "";

  // for XP
  private int nbSentences = -1;
  private int nbSameValence = -1;

  // constructor for a screen
  Stage(String label) {
    type = 0;
    this.label = label;
  }

  // constructor for xp
  Stage(int nbSentences, int nbSameValence) {
    type = 1;
    this.nbSentences = nbSentences;
    this.nbSameValence = nbSameValence;
    // init list for likerts
    likertsAgent = new ArrayList<String>();
    likertsSentence = new ArrayList<String>();
  }

  // high-level function for pushing likert to stack
  public void pushLikert(String likert, String type) {
    if (type.equals("sentence")) {
      pushLikertSentence(likert);
    }
    else if (type.equals("agent")) {
      pushLikertAgent(likert);
    }
    else {
      println("Error, unknown likert type, ignore it.");
    }
  }

  // for testing: push (sort of a) likert for sentences
  private void pushLikertSentence(String label) {
    println("New likert for sentences.");
    likertsSentence.add(label);
  }

  // for testing: push (sort of a) likert for agent
  private void pushLikertAgent(String label) {
    println("New likert for agent.");
    likertsAgent.add(label);
  }

  // before draw: update internal states
  public void update() {
    // check if it's time to go in case it's an xp type
    if (type==1 && millis() > start_time + SHOW_TIME ) {
      println("timeout!");
      desactivate();
    }
  }

  // draw on screen
  public void draw() {
    // different behavior depending of type
    switch (type) {
      // title
    case 0:
      background(0);
      fill(255);
      text(label, 30, 30);
      break;
      // xp
    case 1:
      background(0);
      fill(255);
      rect(10, 10, 300, 300);
      break;
      // dummy text if we don't know who we are
    default:
      background(0);
      fill(255);
      text("???", 30, 30);
    }
  }

  // is it currently active? (ie: is it time to go on next stage?)
  public boolean isActive() {
    return active;
  }

  // to die is a private thing
  private void desactivate() {
    println("I'm letting it go!");
    active = false;
  }

  // tell it to go on-stage
  public void activate() {
    active = true;
    start_time = millis();
  }

  // sent click event
  public void clicked() {
    // usefull for title type: time to go
    if (type ==  0) {
      desactivate();
    }
  }
}
