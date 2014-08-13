
import processing.core.PApplet;

// handles info about what's currently going on during the XP
// This is the main place where draw occurs ; a stage filling the entire screen. Drawing area will update automatically to widow size.
// Use this class for unknown stages, otherwise StageTitle or StageXP

public abstract class Stage {
  // counter for identifying stage
  private static int nbStages = 0;
  // one private ID used for CSV logging
  protected int ID;
  
  // Is it obvious that this class was previously an inner of main prog?
  private PApplet applet;

  // will wait signal before going to work and will disable by itself when job's done
  private boolean active = false;

  // FIXME: leftovers
  // a timer since activation
  private int startTime = 0;
  // how many time in ms should the timer be set
  private int timerDuration = 0;

  // tell the exterior world what's going on
  protected Maestro.Trigger trig;

  // record screen width/height to fit to screen if needed 
  private int lastScreenHeight = -1;
  private int lastScreenWidth = -1;

  // child class should call this constructor, we need to set trigger and update id!
  Stage (PApplet applet, Maestro.Trigger trig) {
    this.applet = applet;
    this.trig = trig;
    this.ID = nbStages++;
  }

  // before draw: update internal states
  // child class should call this method: check if needed to call fitScreen()
  public void update() {
    if (lastScreenHeight != applet.height || lastScreenWidth != applet.width) {
      fitScreen();
      lastScreenHeight =  applet.height;
      lastScreenWidth = applet.width;
    }
  }

  // draw on screen, minimum requieremnts for sub-classes 
  abstract public void draw();

  // will start a timer
  // timeDuration: for how long (in ms)
  final protected void startTimer(int timerDuration) {
    // reset start
    startTime = applet.millis();
    // update duration
    this.timerDuration = timerDuration;
    Diary.println("Start timer for duration=" + timerDuration + "ms at t=" + startTime + "ms");
  }

  // is the timer over yet?
  final protected boolean isTimeOver() {
    return applet.millis() >= startTime+timerDuration;
  }

  // is it currently active? (ie: is it time to go on next stage?)
  public boolean isActive() {
    return active;
  }

  // to die is a private thing
  // child class should call this method -- sends code
  // TODO: cleanup agent maybe...
  protected void desactivate() {
    Diary.println("I'm letting it go!");
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

  // to be called upon window resize, does not much
  public void fitScreen() {
    applet.println("Resizing stage...");
  }
}

