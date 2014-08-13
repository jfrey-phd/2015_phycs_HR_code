
// A stage which handles title screens : label at max size in the middle of the srceen.
// Wait for click to disable

public class StageTitle extends Stage {

  // for screen
  private String label = "";
  // position and size of the text
  private float labelX = 0;
  private float labelY = 0;
  private float labelHeight = 1;

  // space the title will take on screen
  private final float TEXT_AREA = 0.8;

  // constructor for a screen
  StageTitle(Trigger trig, String label) {
    super(Maestro.this, trig);
    this.label = label;
  }

  // draw for title type
  public void draw() {
    background(0);
    fill(255);
    textSize(labelHeight);
    textAlign(CENTER, CENTER);
    text(label, labelX, labelY);
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

  // adapt label heiht and position
  public void fitScreen() {
    super.fitScreen();
    // reset text size
    labelHeight = 1;
    textSize(labelHeight);
    // make label grow until it overflows text area, in X or in Y 
    while (textWidth (label) < width*TEXT_AREA && labelHeight < height*TEXT_AREA) {
      textSize(++labelHeight);
    }
    // when loop exits, we've gone one step too far
    labelHeight--;
    // update center position
    labelX = width/2;
    labelY = height/2;
  }
} 

