
// handles info about what's currently going on during the XP
// This is the main place where draw occurs ; a stage filling the entire screen.
// Use this class for unknown stages, otherwise StageTitle or StageXP

public abstract class Stage {

  // will wait signal before going to work and will disable by itself when job's done
  private boolean active = false;

  // FIXME: leftovers
  // a timer since activation
  private int startTime = 0;
  // how many time in ms should the timer be set
  private int timerDuration = 0;

  // tell the exterior world what's going on
  protected Trigger trig;

  // child class should call this constructor, we need to set trigger!
  Stage (Trigger trig) {
    this.trig = trig;
  }

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
  // child class should call this method -- sends code
  // TODO: cleanup agent maybe...
  protected void desactivate() {
    println("I'm letting it go!");
    active = false;
    sendStim("OVTK_StimulationId_SegmentStop");
  }

  // tell it to go on-stage
  // creates agent if type XP
  // child class should call this method -- sends stim code + adapt size to screen
  public void activate() {
    active = true;
    sendStim("OVTK_StimulationId_SegmentStart");
    // screen size may have changed since creation
    fitScreen();
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

  // wrapper for Trigger.sendMes for child classes
  final protected void sendStim(String code) {
    trig.sendMes(code);
  }

  // to be called upon window resize, does nothing by default
  public void fitScreen() {
  }
}

