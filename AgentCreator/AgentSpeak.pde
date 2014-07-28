
// to be called in setup()
void AgentSpeak_setup() {
  // load wrapper
  System.loadLibrary("javaspeak");
  // init TTS 
  // Speak.setVoice("fr");
  Speak.initialise("french-mbrola-1", 1) ;
  Speak.setVoice("french-mbrola-4");
  //Speak.setPitch(150) ;
  //Speak.setPitchRange(50);
  //Speak.setRate(150);
  //Speak.setWordgap(2);
}

// will interrupt program if not called with thread()
void speak() {
  Speak.espeak("Bonjour tout le monde et bonjour et bonjour !");
}

