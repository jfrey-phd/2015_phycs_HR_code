
// handles info about what's currently going on during the XP
// this is the main place where draw occurs...
// Use this class for unknown stages, otherwise StageTitle or StageXP

public abstract class Stage {
  // 0: title
  // 1: xp
  private int type = -1;

  // will wait signal before going to work and will disable by itself when job's done
  private boolean active = false;

  // FIXME: leftovers
  // a timer since activation
  private int start_time = 0;
  // how many time in ms should this stage be active (for title)
  private final int SHOW_TIME = 2000;

  // before draw: update internal states
  // by default: nothing
  public void update() {
  }

  // draw on screen, minimum requieremnts for sub-classes 
  abstract public void draw();

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
    start_time = millis();
  }

  // sent click event
  // by default, does nothing
  public void clicked() {
  }
}
