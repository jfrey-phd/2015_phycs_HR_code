
class LikertScale {
  // how may choices do we have ?
  private int nbButtons;
  // holds our precious buttons
  ArrayList<LikertButton> buttons;

  // position and width on screen
  private float posX, posY, size;
  // associated question
  private String label = "?";
  // vertical space allocated for text
  private float TEXT_HEIGHT = 40;

  // create
  LikertScale(String label, int nbButtons, float posX, float posY, float size) {
    this.label = label;
    this.nbButtons = nbButtons;
    this.posX = posX;
    this.posY = posY;
    this.size = size;
    // really, should not happen, but since we divide by nbButtons later...
    if (nbButtons < 1) {
      println("Odd: a likert scale with no buttons?");
      return;
    }
    buttons = new ArrayList<LikertButton>();
    // each space allocated to the buttons will have 80% of actual button and 20% of space around
    float button_size = (size/nbButtons) * 4/5;
    // populate list of buttons
    for (int i=0; i<nbButtons; i++) {
      // FIXME: better labels...
      String button_label = Integer.toString(i);
      println("Create button: " + button_label);
      // X position depends on button number, Y position makes room for the question
      float buttonX = i * (size/nbButtons) + posX;
      float buttonY = posY + TEXT_HEIGHT*1.5;
      // push button to stack
      buttons.add(new LikertButton(button_label, buttonX, buttonY, button_size));
    }
  }

  public void draw() {
    // draw text in the top middle
    fill(0);
    textAlign(CENTER, TOP);
    textSize(TEXT_HEIGHT);
    text(label, posX+size/2, posY);
    // a line for positionning debug
    line(posX, posY, size, posY);
    // then draw each button
    for (int i=0; i<buttons.size(); i++) {
      buttons.get(i).draw();
    }
  }
}

