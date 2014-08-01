
// a set of clickable buttons with different labels associated and a question to be answered

class LikertScale {
  // how may choices do we have ?
  private int nbButtons;
  // holds our precious buttons
  ArrayList<LikertButton> buttons;
  // which one is selected ?
  int clicked_ID = -1;
  // won't change after click (nor select more than one button) if true
  private boolean disable_on_click;
  // remember the current active state of the likert scale
  private boolean disabled = false;

  // position and width on screen
  private float posX, posY, size;
  // associated question
  private String label = "?";
  // vertical space allocated for text
  private float TEXT_HEIGHT = 40;

  // create the scale, with its label, the number of propositions and the position
  LikertScale(String label, int nbButtons, float posX, float posY, float size, boolean disable_on_click) {
    this.label = label;
    this.nbButtons = nbButtons;
    this.posX = posX;
    this.posY = posY;
    this.size = size;
    this.disable_on_click = disable_on_click;
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
      buttons.add(new LikertButton(button_label, i, buttonX, buttonY, button_size, disable_on_click));
    }
  }

  // draw each button + label
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

  // update buttons status. If a press occurrs (flag == true) then button hovered by mouse, if any, will have its status updated
  // if a release occured (false), a button presivously marked as "pressed" will be clicked.
  // update the ID of the selected button (see getClickedButton())
  // disable the likert scale (and each individual buttons) if disable_on_click is set
  public void sendMousePress(boolean flag) {
    // if disabled, no use to go below
    if (disabled) {
      return;
    }
    // first update press/detect click
    for (int i=0; i<buttons.size(); i++) {
      LikertButton button = buttons.get(i);
      // if it just a "press", then update only this status
      if (flag) {
        // let's make them work by themselves!
        button.setPressed(button.isMouseHover());
      }
      // if released, check if it still on button and was previously pressed and if it was... bingo, it's a click!
      else {
        if (button.isMouseHover() && button.isPressed()) {
          button.setClicked();
          clicked_ID = button.getID();
        }
        button.setPressed(false);
      }
    }

    // if a click occurred and disable_on_click is set, we have to disable every button
    if (clicked_ID >= 0 && disable_on_click) {
      for (int i=0; i<buttons.size(); i++) {
        buttons.get(i).disable();
      }
      disabled=true;
    }
  }

  // return the ID of the button pressed (-1 if none).
  // NB: return the last clicked button or, if severeal button are clicked (multitouch??), the highest ID, 
  public int getClickedButton() {
    return clicked_ID;
  }

  // client can know if it is useful to send event or take click into account
  public boolean isDisabled() {
    return disabled;
  }
}

