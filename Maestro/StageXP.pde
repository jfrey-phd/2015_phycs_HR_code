
import java.util.Locale;

// A stage which handles agents, will disable by itself when job's done.
// Agents are randomely generated, exept for HR which is set by XML.
// Once agents (HR conditions) are added to the list, the new agent will be randomely. 

// If option is set, will write data in CSV format about each answer of the subject.

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

  // current agent, corpus and tts system
  private Agent agent;
  private Corpus corpus;
  private AgentSpeak tts;
  // we need to pass HR information to agents
  private HeartManager hrMan;
  // total number of sentence per agent/same valence in a raw
  private int nbSentences = -1;
  private int nbSameValence = -1;
  // counter for current sentence number/valence
  private int curSentenceNb = 0;
  private int curSameValence = 0;
  // wich valence we are using right now (chosen in step SPEAK_START)
  private int curValence = 0;
  // current sentence, used to hold info between pick and subject answer
  private Corpus.Sentence sentence;

  // for how long we'll put stage on sleep when we have the occasion to (e.g. end of likerts + end of sentences) (in ms)
  final private int TIMER_DURATION = 500;

  // constructor for xp, create new agent, link it against AgentSpeak if available
  StageXP(Trigger trig, HeartManager hrMan, Corpus corpus, AgentSpeak tts, int nbSentences, int nbSameValence) {
    super(Maestro.this, trig);
    this.corpus = corpus;
    this.hrMan = hrMan;
    // init variables, list for likerts and HRs
    this.nbSentences = nbSentences;
    this.nbSameValence = nbSameValence;
    HRs = new ArrayList<Body.HR>();
    likertsAgent = new ArrayList<LikertScale>();
    likertsSentence = new ArrayList<LikertScale>();

    // point to tts engine
    this.tts = tts;
  }

  // polling while current agent, if any, is cleaning up
  // to be called before createAgent()!
  private boolean agentClean() {
    if (agent != null) {
      // if agent is clean, remove reference
      if (agent.cleanup()) {
        agent = null;
        return true;
      }
      // at this point, agent is present, but *not* clan
      return false;
    }
    // no more agent
    return true;
  }

  // will create a new agent. Call agentClean() first -- and wait for it to return true! 
  // new agent, randomely selected among HR conditions left, removing from stack
  private void createAgent() {
    if (HRs.size() > 0) {
      // randomely select an index from array and get element
      int index = int(random(HRs.size()));
      Body.HR HRType = HRs.get(index);
      println("Creating new agent: selects id=" + (index + 1) + "/" + HRs.size() + ", type: " + HRType);
      // creates according agent, remove HR condition from list.
      // "trig" ref comes from parent class... and passed by this one during creation
      // TODO: make way better use of trig for HR
      agent = new Agent(HRType, hrMan, trig);
      println("Selected agent: " + agent);
      HRs.remove(index);
      // point to TTS (for mouth animation)
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
    } else if (type.equals("agent")) {
      pushLikertAgent(question, nbButtons, from, neutral, to);
    } else {
      println("Error, unknown likert type, ignore it.");
    }
  }

  // push likert for sentences
  // question + how may answers + labels for answers
  // NB: likert postion computed in fitScreen()
  private void pushLikertSentence(String question, int nbButtons, String from, String neutral, String to) {
    println("New likert for sentences. Question: " + question + ", [" + nbButtons + "], labels " + from + ", " + neutral + ", " + to);
    // disable on click and fade, dummy positions
    LikertScale likert = new LikertScale(question, nbButtons, 0, 0, 100, true, 5);
    // set labels
    likert.setLabels(from, neutral, to);
    likertsSentence.add(likert);
  }

  // push likert for agent
  // question + how may answers + labels for answers
  // NB: likert postion computed in fitScreen()
  private void pushLikertAgent(String question, int nbButtons, String from, String neutral, String to) {
    println("New likert for agent. Question: " + question + ", [" + nbButtons + "], labels " + from + ", " + neutral + ", " + to);
    // disable on click and fade, dummy positions
    LikertScale likert = new LikertScale(question, nbButtons, 0, 0, 100, true, 5);
    // set labels
    likert.setLabels(from, neutral, to);
    likertsAgent.add(likert);
  }

  // choose new valence for next sentences
  private void resetValence() {
    curSameValence = 0;
    // valence between -1 and 1
    curValence = floor(random(-1, 2));
    println("New valence for next " + nbSameValence + " sentences: " + curValence);
  }

  // before draw: update internal states
  // NB: could takes few loop to reach a useful state
  // see StageState for a diagram  of the state
  public void update() {
    super.update();
    switch(curState) {
      // automatically switch to START...
    case INIT:
      curState = StageState.XP.START;
      println("State: " + curState);
      break;
      // will ask for the creation of a new agent, eventually wait for the previous one to cleanup, reset sentences counters
      // if no more agents: END of xp
    case START:
      if (HRs.size() == 0) {
        curState = StageState.XP.STOP;
        println("State: " + curState);
      } else {
        // only go with new agent if the previous one as clean
        if (agentClean()) {
          createAgent();
          curState = StageState.XP.AGENT_START;
          println("State: " + curState);
          // start a new batch
          curSentenceNb = 0;
          resetValence();
          sentence = null;
          sendStim("OVTK_StimulationId_TrialStart");
          // we need to be a little more precise than that, pass code of HR type directly to trigger
          sendStim(agent.HRType.code);
        }
      }
      break;
    case AGENT_START:
      // may have a break between sentences set by SPEAK_STOP
      if (isTimeOver()) {
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
        // no sentence and no likert: back to begining
        else {
          curState = StageState.XP.START;
          println("State: " + curState);
        }
      }
      break;
      // initiate next sentence or next step if no more in valence/agent
      // TODO: select valence, use corpus
    case SPEAK_START:
      // increase the number of same valence we used in a row
      curSameValence++;
      // if greater that what we should say, reset counter, draw new valence
      if (curSameValence > nbSameValence) {
        resetValence();
      }
      // draw a new sentence
      sentence = corpus.drawText(curValence);
      // speak it aloud if present
      if (sentence != null) {
        tts.speak(sentence.text, agent.genre, agent.voicePitch);
      }
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
        // small pause between sentences, welcome break even if no likerts
        startTimer(TIMER_DURATION);
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
      for (int i = 0; i < likertsSentence.size (); i++) {
        LikertScale lik = likertsSentence.get(i);
        // one is active, change flag
        if (!lik.isDisabled()) {
          sentence_active = true;
        }
        // if not, checks if new answers should be aknowledge
        else {
          // we got once the last button clicked, pass info for stims/CSV
          int lastClick = lik.getLastClick();
          if (lastClick != -1) {
            likertAnswered(true, i, lik.nbButtons, lastClick);
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
        for (int i = 0; i < likertsSentence.size (); i++) {
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
      for (int i = 0; i < likertsAgent.size (); i++) {
        LikertScale lik = likertsAgent.get(i);
        // one is active, change flag, stop loop
        if (!lik.isDisabled()) {
          agent_active = true;
        }
        // if not, checks if new answers should be aknowledge
        else {
          // we got once the last button clicked, pass info for stims/CSV
          int lastClick = lik.getLastClick();
          if (lastClick != -1) {
            likertAnswered(false, i, lik.nbButtons, lastClick);
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
        for (int i = 0; i < likertsAgent.size (); i++) {
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

  // will send the correct stim and export to CSV once a quesiton has been answerd
  // likertSentence: true if the likert is about a sentence, false for an agent
  // likertNumber, buttonNumber: code for selected button of selected likert
  // nbButtons: how many buttons holds the scale (used for stims)
  // TODO: stims not scalable with number of likerts
  private void likertAnswered(boolean likertSentence, int likertNumber, int nbButtons, int buttonNumber) {
    // buttons are sequentially numbered between the scales
    int butCode = likertNumber*nbButtons + buttonNumber;

    // which is the first label dedicated to this likert scale...
    int labelStart;
    // ...and an associated plain text name... 
    String questionType = "";
    // ...if comes from likertsSentence
    if (likertSentence) {
      labelStart = 1;
      questionType = "sentence";
    }
    // ...if comes from likertsAgent
    else {
      labelStart = 8;
      questionType = "agent";
    }

    // send stim, we have to convert button number to hexa for openvibe stim code (need only 2 digits)
    String stimCode = "OVTK_StimulationId_Label_" + hex(labelStart + butCode, 2);
    println("Button click for Stage: " + butCode + ", code: " + stimCode);
    sendStim(stimCode);

    // will write CSV file now if option set
    // TODO: we do not deal with the flag for stim in here, better think of that
    if (exportCSV) {
      // set default condtion for current sentence
      Corpus.Type corpus_type = Corpus.Type.UNKNOWN;
      float orig_valence = 0;
      int valence = 0;
      // then try to read what has actually been spoken 
      if (sentence != null) {
        corpus_type = sentence.corpusType;
        orig_valence = sentence.origValence;
        valence = sentence.valence;
      }
      Diary.logCSV(ID, agent.HRType, corpus_type, orig_valence, valence, questionType, likertNumber, buttonNumber);
    }
  }

  // draw for xp type
  // may show likert if in correct state
  // TODO: size depending on window
  // TODO: size depeding on number of questions
  public void draw() {
    // reset display
    background(255);

    // By default, agent takes 4/5 of the screen
    // (leave space for likert sentence no matter what even if not shown, too frequent change in position would disturb user)
    // TODO: adapt with number of likert sentence
    float agentSpace = 0.8;

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
      for (int i=0; i < likertsAgent.size (); i++) {
        likertsAgent.get(i).draw();
      }
    case LIKERT_AGENT_START:
      // there will be many likerts for agent, reduce space
      // TODO: adapt with number of likert agent
      agentSpace = 0.4;
      break;
      // loop on sentence likerts to draw them
    case LIKERT_SENTENCE:
    case LIKERT_SENTENCE_STOP:
      // loop on likerts to draw them
      for (int i=0; i < likertsSentence.size (); i++) {
        likertsSentence.get(i).draw();
      }
      break;
    }

    // if the current state don't prevent agent diplay, show the beautiful baby
    if (showAgent && agent != null) {

      // original agent size is 1000x1000 (see Agent). Center on X, scale on Y.
      // The real scale of agent is a little less than "agentSpace" because there is space left above and under
      float agentScale = (agentSpace * 18/20) * height / 1000;
      // center by hand on X, on top on Y
      float agentX = (width - (height*agentScale)) / 2;
      // 1/20 margin
      float agentY = height * (agentScale * 1/20);

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
      for (int i=0; i < likertsSentence.size (); i++) {
        // if enabled, send event
        likertsSentence.get(i).sendMousePress(true);
      }
    }
    // loop for agent
    else if (curState == StageState.XP.LIKERT_AGENT)
    {
      for (int i=0; i < likertsAgent.size (); i++) {
        // send event
        likertsAgent.get(i).sendMousePress(true);
      }
    }
  }

  // send event to all the corresponding and active likerts while in LIKERT_SENTENCE or LIKERT_AGENT
  public void released() {
    // loop for sentence
    if (curState == StageState.XP.LIKERT_SENTENCE) {
      for (int i=0; i < likertsSentence.size (); i++) {
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
      for (int i=0; i < likertsAgent.size (); i++) {
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

  // called by fitScreen, resize one of the sets of likerts, leaving agentRatio space for agent display
  private void resizeLikerts(ArrayList<LikertScale> likerts, float agentRatio) {
    // TODO: the ratio height=width*2.5 for likerts is a bit guessed, could be computed from buttons/likerts
    float likertWidthHeightRatio = 2.5;
    for (int i=0; i < likerts.size (); i++) {
      // how much space left for likert in Y
      float likertSpaceY = height*(1-agentRatio);
      // compute how much space il allocated per likert
      float likertHeight = likertSpaceY/likerts.size ();
      // compute corresponding width to pass to likert to make it fit the space -- not more than screen width though
      float likertWidth = min(width, likertHeight * likertWidthHeightRatio);
      // give room for previous likerts
      float likertY = height*agentRatio +  likertHeight*i;
      // center in X
      float likertX = (width - likertWidth)/2;
      // send positions
      likerts.get(i).move(likertX, likertY, likertWidth);
    }
  }

  // call when window size change, update likerts positions
  public void fitScreen() {
    super.fitScreen();
    // for likert sentences, agent fills 4/5 of the screen
    resizeLikerts(likertsSentence, 0.8);
    // for likert agent, agent fills 2/5 of the screen
    resizeLikerts(likertsAgent, 0.4);
  }
}

