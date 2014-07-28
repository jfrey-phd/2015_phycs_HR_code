
// currently speaking
boolean speaking = false;

String TTS_script_cmd = "";
// to be called in setup()
void AgentSpeak_setup() {
  TTS_script_cmd = sketchPath("") + "code/speak.sh";
  println("TTS script location: " + TTS_script_cmd);
}

// will interrupt program if not called with thread()
// NB: only one at a time, should check isSpeaking() before calling this method
void speak() {
  String mes = "Bonjour tout le monde et bonjour et bonjour !";
  println("Will say: [" + mes + "].");
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
    mes
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

boolean isSpeaking() {
  return speaking;
}

