
import java.util.Locale;

// a stage which handles agents, will disable by itself when job's done
// agents are randomely generated, exept for HR which is set by XML.
// once agents (HR conditions) are added to the list, the new agent will be randomely 

public class StageXP extends Stage {

  // state for keeping track of what we have to do
  private StageState.XP curState = StageState.XP.INIT;

  // array list for agents conditions -- here we just to store HR
  // NB: element of lists are removed when a new agent is created
  private ArrayList<Body.HR> HRs;

  // array list of likert scale for sentences
  private ArrayList<LikertScale> likertsSentence; 
  // array list of  likert scale for agent
  private ArrayList<LikertScale> likertsAgent; 

  // current agent and tts system
  private Agent agent;
  private AgentSpeak tts;
  // total number of sentence per agent/same valence in a raw
  private int nbSentences = -1;
  private int nbSameValence = -1;
  // counter for current sentence number/valence
  private int curSentenceNb = 0;
  private int curSameValence = 0;

  // for how long we'll put stage on sleep when we have the occasion to (e.g. end of likerts) (in ms)
  final private int TIMER_DURATION = 1000;

  // constructor for xp, create new agent, link it against AgentSpeak if available
  StageXP(Trigger trig, AgentSpeak tts, int nbSentences, int nbSameValence) {
    super(trig);
    // init variables, list for likerts and HRs
    this.nbSentences = nbSentences;
    this.nbSameValence = nbSameValence;
    HRs = new ArrayList<Body.HR>();
    likertsAgent = new ArrayList<LikertScale>();
    likertsSentence = new ArrayList<LikertScale>();

    // point to tts engine
    this.tts = tts;
  }

  // will create/reset agent
  // new agent, randomely selected among HR conditions left, removing from stack
  // TODO: randomize TTS
  private void createAgent() {
    if (HRs.size() > 0) {
      // randomely select an index from array and get element
      int index = int(random(HRs.size()));
      Body.HR HRType = HRs.get(index);
      println("Creating new agent: selects id=" + (index + 1) + "/" + HRs.size() + ", type: " + HRType);
      // creates according agent, remove HR condition from list
      agent = new Agent(HRType);
      HRs.remove(index);
      // point to TTS
      agent.setTTS(tts);
    }
    // should not happen -- update() in START already checks this
    else {
      println("Error: no more HR conditions for new agents");
    }
  }

  // add a new agent condition to the stage * nbTimes
  // at least one for something to appear...
  public void pushAgent(String type, int nbTimes) {
    // convert from lower case string to enum
    // see javadoc for comment about locale selection
    Body.HR HRType = Body.HR.valueOf(type.toUpperCase(Locale.ENGLISH));
    println("Adding " + nbTimes + " agents of type " + HRType);
    // as many agent as they want
    for (int i = 0; i < nbTimes; i++) {
      HRs.add(HRType);
    }
  }

  // high-level function for pushing likert to stack
  // type +  question + how may answers + labels for answers
  public void pushLikert(String type, String question, int nbButtons, String from, String neutral, String to) {
    if (type.equals("sentence")) {
      pushLikertSentence(question, nbButtons, from, neutral, to);
    }
    else if (type.equals("agent")) {
      pushLikertAgent(question, nbButtons, from, neutral, to);
    }
    else {
      println("Error, unknown likert type, ignore it.");
    }
  }

  // push likert for sentences
  // question + how may answers + labels for answers
  // FIXME: will fix positions here...
  private void pushLikertSentence(String question, int nbButtons, String from, String neutral, String to) {
    println("New likert for sentences. Question: " + question + ", [" + nbButtons + "], labels " + from + ", " + neutral + ", " + to);
    // set width and position
    float likertSize = 500;
    float likertX = 100;
    // magic numbers + give room for previous likerts
    float likertY = 800 +  100*likertsSentence.size();
    // disable on click and fade
    LikertScale likert = new LikertScale(question, nbButtons, likertX, likertY, likertSize, true, 5);
    // set labels
    likert.setLabels(from, neutral, to);
    likertsSentence.add(likert);
  }

  // push likert for agent
  // question + how may answers + labels for answers
  // FIXME: will fix positions here...
  private void pushLikertAgent(String question, int nbButtons, String from, String neutral, String to) {
    println("New likert for agent. Question: " + question + ", [" + nbButtons + "], labels " + from + ", " + neutral + ", " + to);
    // set width and position
    float likertSize = 500;
    float likertX = 100;
    // magic numbers + give room for previous likerts
    float likertY = 400 +  200*likertsAgent.size();
    // disable on click and fade
    LikertScale likert = new LikertScale(question, nbButtons, likertX, likertY, likertSize, true, 5);
    // set labels
    likert.setLabels(from, neutral, to);
    likertsAgent.add(likert);
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
      // will ask for the creation of a new agent, reset sentences counters
      // if no more agents: END of xp
    case START:
      if (HRs.size() == 0) {
        curState = StageState.XP.STOP;
        println("State: " + curState);
      }
      else {
        createAgent();
        curState = StageState.XP.AGENT_START;
        println("State: " + curState);
        // start a new batch
        curSentenceNb = 0;
        curSameValence = 0;
        sendStim("OVTK_StimulationId_TrialStart");
        // we need to be a little more precise than that, pass code of HR type directly to trigger
        sendStim(agent.getHRType().code);
      }
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
        println("There is " + likertsAgent.size() + " likerts for agents");
        curState = StageState.XP.LIKERT_AGENT_START;
        println("State: " + curState);
        sendStim("OVTK_GDF_Flashing_Light");
      }
      // no sentence and no likert: stop agent
      // TODO: back to start when agent list
      else {
        curState = StageState.XP.STOP;
        println("State: " + curState);
      }
      break;
      // initiate next sentence or next step if no more in valence/agent
      // TODO: select valence, use corpus
    case SPEAK_START:
      thread("speak");
      curState = StageState.XP.SPEAKING;
      println("State: " + curState);
      sendStim("OVTK_StimulationId_VisualStimulationStart");
      // FIXME: valence
      sendStim("OVTK_GDF_Foot");
      break;
      // wait untill tts is done
    case SPEAKING:
      if (!tts.isSpeaking()) {
        curState = StageState.XP.SPEAK_STOP;
        println("State: " + curState);
        sendStim("OVTK_StimulationId_VisualStimulationStop");
      }
      break;
      // check for likert
    case SPEAK_STOP:
      // check for likert on sentence
      if (likertsSentence.size() > 0) {
        println("There is " + likertsSentence.size() + " likerts for sentence");
        curState = StageState.XP.LIKERT_SENTENCE_START;
        println("State: " + curState);
        sendStim("OVTK_GDF_Cross_On_Screen");
      } 
      // if  no likert, back to agent
      else {
        curState = StageState.XP.AGENT_START;
        println("State: " + curState);
      }
      break;
      // init wait for click
    case LIKERT_SENTENCE_START:
      curState = StageState.XP.LIKERT_SENTENCE;
      println("State: " + curState);
      break;
      // show likert for sentence while at least one is active
    case LIKERT_SENTENCE:
      boolean sentence_active = false;
      for (int i = 0; i < likertsSentence.size(); i++) {
        LikertScale lik = likertsSentence.get(i);
        // one is active, change flag
        if (!lik.isDisabled()) {
          sentence_active = true;
        }
        // if not, checks if new answers should be aknowledge
        else {
          // we got once the last button clicked, compute corresponding stim code and send
          int lastClick = lik.getLastClick();
          if (lastClick != -1) {
            // buttons are sequentially numbered between the scales
            int butNumber = i*lik.nbButtons + lastClick;
            // which is the first label dedicated to this likert scale
            // TODO: not scalable with number of likerts
            int labelStart = 1;
            // we have to convert button number to hexa for openvibe stim code (need only 2 digits)
            String stimCode = "OVTK_StimulationId_Label_" + hex(labelStart + butNumber, 2);
            println("Button click for Stage: " + butNumber + ", code: " + stimCode);
            sendStim(stimCode);
          }
        }
      }
      // if no active state, then can go
      if (!sentence_active) {
        curState = StageState.XP.LIKERT_SENTENCE_STOP;
        println("State: " + curState);
        // launch timer
        startTimer(TIMER_DURATION);
        sendStim("OVTK_GDF_Correct");
      }
      break;
      // reset sentence likerts for next use
      // wait for time's up before proeceeding
    case LIKERT_SENTENCE_STOP:
      if (isTimeOver()) {
        for (int i = 0; i < likertsSentence.size(); i++) {
          likertsSentence.get(i).reset();
        }
        curState = StageState.XP.AGENT_START;
        println("State: " + curState);
      }
      break;
      // some likert for agent
      // init wait for click
    case LIKERT_AGENT_START:
      curState = StageState.XP.LIKERT_AGENT;
      println("State: " + curState);
      break;
      // show likert for agent while at least one is active
    case LIKERT_AGENT:
      boolean agent_active = false;
      for (int i = 0; i < likertsAgent.size(); i++) {
        LikertScale lik = likertsAgent.get(i);
        // one is active, change flag, stop loop
        if (!lik.isDisabled()) {
          agent_active = true;
        }
        // if not, checks if new answers should be aknowledge
        else {
          // we got once the last button clicked, compute corresponding stim code and send
          int lastClick = lik.getLastClick();
          if (lastClick != -1) {
            // buttons are sequentially numbered between the scales
            int butNumber = i*lik.nbButtons + lastClick;
            // which is the first label dedicated to this likert scale
            // TODO: not scalable with number of likerts
            int labelStart = 8;
            // we have to convert button number to hexa for openvibe stim code (need only 2 digits)
            String stimCode = "OVTK_StimulationId_Label_" + hex(labelStart + butNumber, 2);
            println("Button click for Stage: " + butNumber + ", code: " + stimCode);
            sendStim(stimCode);
          }
        }
      }
      // if no active state, then can go
      if (!agent_active) {
        curState = StageState.XP.LIKERT_AGENT_STOP;
        println("State: " + curState);
        // launch timer
        startTimer(TIMER_DURATION);
        sendStim("OVTK_GDF_Correct");
      }
      break; 
      // likert done: stop agent, reset agent likerts for next use (? should not happen), back to START
    case LIKERT_AGENT_STOP:
      if (isTimeOver()) {
        for (int i = 0; i < likertsAgent.size(); i++) {
          likertsAgent.get(i).reset();
        }
        sendStim("OVTK_StimulationId_TrialStop");
        curState = StageState.XP.START;
        println("State: " + curState);
      }
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
    // Tell them what we are !
    // FIXME: handle other corpus
    sendStim("OVTK_GDF_Artifact_Sweat");
  }

  // draw for xp type
  // may show likert if in correct state
  // TODO: size depending on window
  // TODO: size depeding on number of questions
  public void draw() {
    // reset display
    background(255);

    // agent position and scale may change -- if likert agent
    // should be only one likert for sentence, no need to scale -- or would distrub user
    // by default, draw (somewhat) in the middle
    float agentX = 100, agentY = 100;
    // ...and a bit too big on loading
    float agentScale = 0.8;
    // on special case (init and stop), will not show agent to avoid glithes (change in scale for few frames)
    boolean showAgent = true;

    // resize/disable agent + draw likerts if needed 
    switch(curState) {
      // disable agent for special states
    case INIT:
    case START:
    case STOP:
      showAgent = false;
      break;
      // reduces space if likert agent -- will have several questions, makes room
    case LIKERT_AGENT:
    case LIKERT_AGENT_STOP:
      // loop on likerts to draw them
      for (int i=0; i < likertsAgent.size(); i++) {
        likertsAgent.get(i).draw();
      }
    case LIKERT_AGENT_START:
      // agent top left corder
      agentX = 10;
      agentY = 10;
      agentScale = 0.3;
      break;
      // loop on sentence likerts to draw them
    case LIKERT_SENTENCE:
    case LIKERT_SENTENCE_STOP:
      // loop on likerts to draw them
      for (int i=0; i < likertsSentence.size(); i++) {
        likertsSentence.get(i).draw();
      }
      break;
    }

    // if the current state don't prevent agent diplay, show the beautiful baby
    if (showAgent && agent != null) {
      // update every part, deals all animations
      agent.update();
      // reset previous scale, apply new one
      agent.getPShape().resetMatrix();
      agent.getPShape().scale(agentScale);
      // draw (somewhat) in the middle
      shape(agent.getPShape(), agentX, agentY);
    }
  }

  // send event to all the corresponding likerts while in LIKERT_SENTENCE or LIKERT_AGENT
  // NB: poor API, but don't need to check for active state here
  public void pressed() {
    // loop for sentence
    if (curState == StageState.XP.LIKERT_SENTENCE) {
      for (int i=0; i < likertsSentence.size(); i++) {
        // if enabled, send event
        likertsSentence.get(i).sendMousePress(true);
      }
    }
    // loop for agent
    else if (curState == StageState.XP.LIKERT_AGENT)
    {
      for (int i=0; i < likertsAgent.size(); i++) {
        // send event
        likertsAgent.get(i).sendMousePress(true);
      }
    }
  }

  // send event to all the corresponding and active likerts while in LIKERT_SENTENCE or LIKERT_AGENT
  public void released() {
    // loop for sentence
    if (curState == StageState.XP.LIKERT_SENTENCE) {
      for (int i=0; i < likertsSentence.size(); i++) {
        // if enabled, send event
        LikertScale likert =  likertsSentence.get(i);
        if (!likert.isDisabled()) {
          likert.sendMousePress(false);
          if (likert.getClickedButton() >= 0) {
            println("Likert clicked!");
          }
        }
      }
    }
    // loop for agent
    else if (curState == StageState.XP.LIKERT_AGENT) {
      for (int i=0; i < likertsAgent.size(); i++) {
        // if enabled, send event
        LikertScale likert =  likertsAgent.get(i);
        if (!likert.isDisabled()) {
          likert.sendMousePress(false);
          if (likert.getClickedButton() >= 0) {
            println("Likert clicked!");
          }
        }
      }
    }
  }
} 

