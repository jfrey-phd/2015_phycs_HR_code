
// a stage which handles agents, will disable by itself when job's done

public class StageXP extends Stage {
  // array list of (sort of) likert scale for sentences
  ArrayList<String> likertsSentence; 
  // array list of (sort of) likert scale for agent
  ArrayList<String> likertsAgent; 

  // for XP
  Agent agent;
  AgentSpeak tts;
  // total number of sentence per agent/same valence in a raw
  private int nbSentences = -1;
  private int nbSameValence = -1;
  // counter for current sentence number/valence
  private int curSentenceNb = 0;
  private int curSameValence = 0;


  // constructor for xp, create new agent, link it against AgentSpeak if available
  StageXP(AgentSpeak tts, int nbSentences, int nbSameValence) {
    // init variables, list for likerts 
    this.nbSentences = nbSentences;
    this.nbSameValence = nbSameValence;
    likertsAgent = new ArrayList<String>();
    likertsSentence = new ArrayList<String>();

    // point to tts engine
    this.tts = tts;
  }

  // will create/reset agent
  private void createAgent() {
    println("(re)creating agent");
    // init for drawing / BPM
    agent = new Agent();
    // a bit to big by default
    agent.getPShape().scale(0.8);
    // point to TTS
    agent.setTTS(tts);
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
    //    if (type==1 && millis() > start_time + SHOW_TIME ) {
    //      println("timeout!");
    //      desactivate();
    //    }
    // if it's XP and no more talking, we have to launch sentences
    // TODO: add timer on top of tts
    if (!tts.isSpeaking()) {
      // still at least one sentence to be told
      if (curSentenceNb < nbSentences) {
        curSentenceNb++;
        println("Will play sentence " + curSentenceNb  + "/" + nbSentences );
        thread("speak");
      }
      // last sentence has been spoken, disable/show likert
      else {
        desactivate();
      }
    }
  }

  // creates agent 
  public void activate() {
    super.activate();
    createAgent();
  }

  // draw for xp type
  public void draw() {
    // reset display
    background(255);
    // update every part, deals all animations
    agent.update();
    // draw (somewhat) in the middle
    shape(agent.getPShape(), 100, 100);
  }
} 
