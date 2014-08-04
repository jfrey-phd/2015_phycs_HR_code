


// a stage which handles agents, will disable by itself when job's done

public class StageXP extends Stage {

  // state for keeping track of what we have to do
  private StageState.XP curState = StageState.XP.INIT;

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

  // TODO: wait for click, debug for likert
  boolean click = false;


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
  // NB: could takes few loop to reach a useful state
  // see StageState for a diagram  of the state
  public void update() {
    switch(curState) {
      // automatically switch to START...
    case INIT:
      curState = StageState.XP.START;
      println("State: " + curState);
      break;
      // new agent
      // TODO: handle agent list
    case START:
      createAgent();
      curState = StageState.XP.AGENT_START;
      println("State: " + curState);
      break;
    case AGENT_START:
      // still at least one sentence to be told
      if (curSentenceNb < nbSentences) {
        curSentenceNb++;
        curState = StageState.XP.SPEAK_START;
        println("State: " + curState);
        println("Will play sentence " + curSentenceNb  + "/" + nbSentences );
      }
      // last sentence has been spoken, check for likert agent
      else if (likertsAgent.size() > 0) {
        curState = StageState.XP.LIKERT_AGENT_START;
        println("State: " + curState);
      }
      // no sentence and no likert: stop agent
      // TODO: back to start when agent list
      else {
        curState = StageState.XP.STOP;
        println("State: " + curState);
      }
      break;
      // initiate next sentence or next step if no more in valence/agent
      // TODO: select valence
    case SPEAK_START:
      thread("speak");
      curState = StageState.XP.SPEAKING;
      println("State: " + curState);
      break;
      // wait untill tts is done
      // TODO: add timer on top of tts
    case SPEAKING:
      if (!tts.isSpeaking()) {
        curState = StageState.XP.SPEAK_STOP;
        println("State: " + curState);
      }
      break;
      // check for likert
    case SPEAK_STOP:
      // check for likert on sentence
      if (likertsSentence.size() > 0) {
        curState = StageState.XP.LIKERT_SENTENCE_START;
        println("State: " + curState);
      } 
      // if  no likert, back to agent
      else {
        curState = StageState.XP.AGENT_START;
        println("State: " + curState);
      }
      break;
      // init wait for click
    case LIKERT_SENTENCE_START:
      click = false;
      curState = StageState.XP.LIKERT_SENTENCE;
      println("State: " + curState);
      break;
      // show likert for sentence while not clicked
    case LIKERT_SENTENCE:
      if (click) {
        curState = StageState.XP.LIKERT_SENTENCE_STOP;
        println("State: " + curState);
      }
      break;
      // not really a thing to do at the moment
    case LIKERT_SENTENCE_STOP:
      curState = StageState.XP.AGENT_START;
      println("State: " + curState);
      break;
      // some likert for agent
      // init wait for click
    case LIKERT_AGENT_START:
      click = false;
      curState = StageState.XP.LIKERT_AGENT;
      println("State: " + curState);
      break;
      // show likert for agent while not clicked
    case LIKERT_AGENT:
      if (click) {
        curState = StageState.XP.LIKERT_AGENT_STOP;
        println("State: " + curState);
      }
      break;
      // likert done: stop agent
      // TODO: back to start when agent list
    case LIKERT_AGENT_STOP:
      curState = StageState.XP.STOP;
      println("State: " + curState);
      break;
      // time to desactivate stage 
    case STOP:
      desactivate();
      break;
      // TODO: timeout to escape infinite loop
    default:
      println("Error, step not handlded: " + curState);
    }
  }

  // launch stages
  public void activate() {
    super.activate();
    curState = StageState.XP.START;
    println("State: " + curState);
  }

  // draw for xp type
  // may show likert if in correct state
  public void draw() {
    // reset display
    background(255);
    // update every part, deals all animations
    agent.update();
    // draw (somewhat) in the middle
    shape(agent.getPShape(), 100, 100);
  }

  // for update() to go to next step
  public void clicked() {
    click = true;
  }
} 
