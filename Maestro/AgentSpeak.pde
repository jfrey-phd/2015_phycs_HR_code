

// Simple API to call an external script for TTS
// ...and to play heart beat for simplification sake

// WARING: ESS need to be initialized beforehand ; put "Ess.start(this)" in setup()

public class AgentSpeak {

  // currently speaking
  private boolean speaking = false;

  // text to be spoken next
  private String agentText = "Bonjour tout le monde.";

  // program location 
  private String TTS_script_cmd = "";

  // in case I want to move it elsewhere...
  private final String PROGRAM_LOCATION = "code/speak.sh";

  // use ESS r2 lib to read audio file
  AudioChannel beat;  

  AgentSpeak() {
    // set path for TTS script
    TTS_script_cmd = sketchPath("") + PROGRAM_LOCATION;
    println("TTS script location: " + TTS_script_cmd);
    // load audio beat
    beat = new AudioChannel("beat.wav");
  }

  // will interrupt program if not called with thread()
  // NB: only one at a time, should check isSpeaking() before calling this method
  public void speak() {
    println("Will say: [" + agentText + "].");
    // Agent has only one mouth
    if (speaking) {
      println("Already speaking, skip this one.");
      return;
    }
    // start to speak
    speaking = true;

    // forge command: script + message
    String[] cmd = {
      TTS_script_cmd, 
      agentText
    };

    Process powershell = exec(cmd);
    // wait for process to finish in order to monitor "speaking" flag
    try {
      powershell.waitFor();
    }
    catch (InterruptedException e) { 
      e.printStackTrace();
    }

    // finished to speak
    speaking = false;
    println("Message finished.");
    //Speak.espeak(");
  }

  // is the TTS script currently executing? should be called before a new speak()
  public boolean isSpeaking() {
    return speaking;
  }

  // set next text to be spoke
  public void setText(String text) {
    agentText = text;
  }

  // plays the heartbeat sound
  // (does not interrupt program)
  public void beat() {
    //reset beat -- with 3ms we avoid noise when play() too close??
    beat.cue(beat.frames(3));
    // got the beat !
    beat.play();
  }
}

