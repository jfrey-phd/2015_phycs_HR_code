
// Simple API to call an external script for TTS
// Function thread() will be used so as not to interrupt program while speaking.
// TODO: use Thread class instead of relying on Maestro

public class AgentSpeak {

  // currently speaking
  private boolean speaking = false;

  // text to be spoken next and associated parameters
  private String agentText = "Bonjour tout le monde.";
  private Body.Genre agentGenre = Body.Genre.FEMALE;
  // default pitch for espeak
  private int agentPitch = 50;

  // program location 
  private String TTS_script_cmd = "";

  // in case I want to move it elsewhere...
  private final String PROGRAM_LOCATION = "code/speak.sh";

  AgentSpeak() {
    // set path for TTS script
    TTS_script_cmd = sketchPath("") + PROGRAM_LOCATION;
    println("TTS script location: " + TTS_script_cmd);
  }

  // run speak command -- use thread() to avoid blocking
  // should be set to private and avoid Maestro.threadSpeak...
  public void execSpeak() {
    // forge command: script + message
    String[] cmd = {
      TTS_script_cmd, 
      agentText, 
      agentGenre.toString(), 
      Integer.toString(agentPitch)
      };

      Process powershell = exec(cmd);
    // wait for process to finish in order to monitor "speaking" flag
    try {
      powershell.waitFor();
    }
    catch (InterruptedException e) { 
      e.printStackTrace();
    }

    // finished to speak, turn off flag set by speak()
    speaking = false;
    println("Message finished.");
  }

  // Will set TTS parameters and then launch command
  // NB: only one at a time, should check isSpeaking() before calling this method
  synchronized public void speak(String sentence, Body.Genre voice, int pitch) {
    println("Will say: [" + agentText + "] with voice " + voice + " and pitch " + pitch);
    // Agent has only one mouth
    if (speaking) {
      println("Already speaking, skip this one.");
      return;
    }
    // will start to speak very soon
    speaking = true;
    // set parameters
    agentText = sentence;
    agentGenre = voice;
    agentPitch = pitch;
    // launch sentence thanks to mamma
    thread("threadSpeak");
  }

  // short version for debug, change only sentence, leave current genre/pitch untouched
  // TODO: remove
  public void speak(String sentence) {
    speak(sentence, agentGenre, agentPitch);
  }

  // is the TTS script currently executing? should be called before a new speak()
  public boolean isSpeaking() {
    return speaking;
  }
}

