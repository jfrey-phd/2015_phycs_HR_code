
// a stage which handles title screens, wait for click to disable

public class StageTitle extends Stage {

  // for screen
  private String label = "";

  // constructor for a screen
  StageTitle(Trigger trig, String label) {
    super(trig);
    this.label = label;
  }

  // draw for title type
  public void draw() {
    background(0);
    fill(255);
    text(label, 30, 30);
  }

  // Tell them what we are !
  public void activate() {
    super.activate();
    sendStim("OVTK_GDF_Artifact_Breathing");
  }

  // time to go when clicked
  public void clicked() {
    desactivate();
  }
} 

