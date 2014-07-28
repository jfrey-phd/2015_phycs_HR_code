
// to be called in setup()
void AgentSpeak_setup() {
  // load wrapper
  System.loadLibrary("javaspeak");
  // init TTS 
  Speak.initialise() ;
  Speak.setPitch(99) ;
  Speak.setPitchRange(99);
}

// will interrupt program if not called with thread()
void speak() {
  Speak.espeak("Hello everybody!");
}

