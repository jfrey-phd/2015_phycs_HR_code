
// test audio file playing with ESS

// use ESS r2 lib
AudioChannel beat;

// rotating buffer to enable burst
AudioChannel[] beats;
int NB_BUFFERS = 10;
int curBuffer;

void setup() {
  // start up Ess
  Ess.start(this);

  beat = new AudioChannel("beat.wav");

  // let's try an array of buffer
  beats = new AudioChannel[NB_BUFFERS];
  // init them
  for (int i = 0; i < beats.length; i++) {
    beats[i] = new AudioChannel("beat.wav");
  }
  curBuffer = 0;
}

void draw() {
  ;
}

// old method, one canal
void oldBeat() {
  //reset beat -- with 3ms we avoid noise when play() too close??
  beat.cue(beat.frames(3));
  // got the beat !
  println("start");
  beat.play();
  println("stop");
}

// new method, rotate buffers
void newBeat() {
  println("start new");
  int i = curBuffer;
  while (beats[i].state != Ess.STOPPED) {
    i++;
    // reset counter if gone too far
    if (i == beats.length) {
      i = 0;
    }
    // if we have done one complete loop: we pass
    if (i == curBuffer) {
      println("No available buffer");
      return;
    }
  }
  // at this point we have an available buffer
  curBuffer = i;
  println("Select buffer: " + curBuffer);
  beats[curBuffer].cue(beats[curBuffer].frames(3));
  beats[curBuffer].play();
  println("stop new");
}

// play beat on mouse press
void mousePressed() {
  if (mouseButton == LEFT) {
    oldBeat();
  } else {
    newBeat();
  }
}

// cleanup
public void stop() {
  println("Stopping..");
  Ess.stop();
  super.stop();
}

