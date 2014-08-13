
// test audio file playing with ESS

// use ESS r2 lib
AudioChannel beat;

void setup() {
  // start up Ess
  Ess.start(this);

  beat = new AudioChannel("beat.wav");
}

void draw() {
  ;
}

// play beat on mouse press
void mousePressed() {
  //reset beat -- with 3ms we avoid noise when play() too close??
  beat.cue(beat.frames(3));
  // got the beat !
  println("start");
  beat.play();
  println("stop");
}


// cleanup
public void stop() {
  println("Stopping..");
  Ess.stop();
  super.stop();
}

