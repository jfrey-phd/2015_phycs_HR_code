
// a stage which handles title screens, wait for click to disable

public class StageTitle extends Stage {

  // for screen
  private String label = "";

  // constructor for a screen
  StageTitle(String label) {
    this.label = label;
  }

  // before draw: update internal states
  public void update() {
  }

  // draw for title type
  public void draw() {
    background(0);
    fill(255);
    text(label, 30, 30);
  }

  // time to go when clicked
  public void clicked() {
    desactivate();
  }
} 
