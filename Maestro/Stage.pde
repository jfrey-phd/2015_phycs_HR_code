
// handles info about what's currently going on during the XP
// this is the main place where draw occurs...
// Use this class for unknown stages, otherwise StageTitle or StageXP

public abstract class Stage {

  // will wait signal before going to work and will disable by itself when job's done
  private boolean active = false;

  // FIXME: leftovers
  // a timer since activation
  private int startTime = 0;
  // how many time in ms should the timer be set
  private int timerDuration = 0;

  // before draw: update internal states
  // by default: nothing
  public void update() {
  }

  // draw on screen, minimum requieremnts for sub-classes 
  abstract public void draw();

  // will start a timer
  // timeDuration: for how long (in ms)
  final protected void startTimer(int timerDuration) {
    // reset start
    startTime = millis();
    // update duration
    this.timerDuration = timerDuration;
    println("Start timer for duration=" + timerDuration + "ms at t=" + startTime + "ms");
  }

  // is the timer over yet?
  final protected boolean isTimeOver() {
    return millis() >= startTime+timerDuration;
  }

  // is it currently active? (ie: is it time to go on next stage?)
  public boolean isActive() {
    return active;
  }

  // to die is a private thing
  // TODO: cleanup agent maybe...
  protected void desactivate() {
    println("I'm letting it go!");
    active = false;
  }

  // tell it to go on-stage
  // creates agent if type XP
  public void activate() {
    active = true;
  }

  // sent click event
  // by default, does nothing
  public void clicked() {
  }

  // sent press event
  // by default, does nothing
  public void pressed() {
  }

  // sent release event
  // by default, does nothing
  public void released() {
  }
}
