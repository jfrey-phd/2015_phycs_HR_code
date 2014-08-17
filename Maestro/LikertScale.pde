
// a set of clickable buttons with different labels associated and a question to be answered
// possible to disable likert scale on click and/or to activate fading effect

class LikertScale {
  // holds our precious buttons
  ArrayList<LikertButton> buttons;
  // how many buttons we got
  public final int nbButtons;
  // which one is selected ?
  int clicked_ID = -1;
  // has clicked button already been sent with getLastClick() ?
  boolean sentClicked = false;
  // won't change after click (nor select more than one button) if true
  private boolean disable_on_click;
  // remember the current active state of the likert scale
  private boolean disabled = false;

  // position and width on screen
  private float posX, posY, size;
  // associated question
  private String label = "?";
  // vertical space allocated for text
  private float textHeight;

  // fade step seleced for appearance/disappearance
  private float fade_step;
  // current transparancy effect
  private float current_alpha = 255;

  // By default we don't care about fade-in/out effect
  LikertScale(String label, int nbButtons, float posX, float posY, float size, boolean disable_on_click) {
    this(label, nbButtons, posX, posY, size, disable_on_click, 0);
  }

  // create the scale, with its label, the number of propositions and the position
  // fade effect: will inscrease by this step tranparancy on appearance at each call of draw (unit: fraction of 255)
  // fade out will automatically occur if disable_on_click is set
  // WARNING: fade smoothness depends on FPS
  LikertScale(String label, int nbButtons, float posX, float posY, float size, boolean disable_on_click, float fade) {
    this.nbButtons = nbButtons;
    this.label = label;
    this.posX = posX;
    this.posY = posY;
    this.size = size;
    // text height is proportional to size, 10%
    this.textHeight = size/10;
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
      // TODO: better labels...
      String button_label = Integer.toString(i);
      println("Create button: " + button_label);
      // X position depends on button number, Y position makes room for the question
      float buttonX = i * (size/nbButtons) + posX;
      float buttonY = posY + textHeight*1.5;
      // push button to stack
      buttons.add(new LikertButton(button_label, i, buttonX, buttonY, button_size, disable_on_click));
    }

    // fade effect, if > 0 enable effect
    this.fade_step = fade;
    if (this.fade_step > 0) {
      // will begin with complete transparancy if effect is set
      current_alpha = 0;
    }
  }

  // replace default labels of buttons with values
  // TODO: results could be weird with an even number of buttons or if < 3
  void setLabels(String from, String neutral, String to) {
    // first pass: empty everything exept begining and end
    for (int i=1; i<buttons.size ()-1; i++) {
      buttons.get(i).setLabel("");
    }
    // then replace firt, last and middle
    if (buttons.size() > 0) { 
      buttons.get(0).setLabel(from);
      buttons.get(buttons.size()/2).setLabel(neutral);
      buttons.get(buttons.size()-1).setLabel(to);
    }
  }

  // draw each button + label
  public void draw() {
    // fade out if disabled
    if (disabled && fade_step > 0 && current_alpha > 0) {
      current_alpha = max(0, current_alpha-fade_step);
    }
    // fade in if appearing
    if (!disabled && fade_step > 0 && current_alpha < 255) {
      current_alpha = min(255, current_alpha+fade_step);
    }
    // draw question text in the top middle
    fill(0, (int)current_alpha);
    textAlign(CENTER, TOP);
    textSize(textHeight);
    text(label, posX+size/2, posY);
    // a line for positionning debug
    //line(posX, posY, size, posY);
    // then draw each button
    for (int i=0; i<buttons.size (); i++) {
      buttons.get(i).draw((int)current_alpha);
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
    for (int i=0; i<buttons.size (); i++) {
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
          sentClicked = false;
        }
        button.setPressed(false);
      }
    }

    // if a click occurred and disable_on_click is set, we have to disable every button
    if (clicked_ID >= 0 && disable_on_click) {
      for (int i=0; i<buttons.size (); i++) {
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

  // a bit different than getClickedButton(): here will return *once* the last clicked button, then reset to -1
  // handy when you want to poll and trigger at each new selection
  public int getLastClick() {
    if (!sentClicked) {
      sentClicked = true;
      return clicked_ID;
    }
    return -1;
  }

  // client can know if it is useful to send event or take click into account
  public boolean isDisabled() {
    return disabled;
  }

  // reset state of the buttons and likerts for re-use
  public void reset() {
    // our variables first, as in header
    disabled = false;
    clicked_ID = -1;
    sentClicked = false;
    // to transparent color if fade effect set
    if (this.fade_step > 0) {
      current_alpha = 0;
    } 
    // should not have been touched if no fade but who knows...
    else {
      current_alpha = 255;
    }
    for (int i=0; i<buttons.size (); i++) {
      buttons.get(i).reset();
    }
  }

  // change likert coordinates
  // TODO: refactorize with constructor
  public void move(float posX, float posY, float size) {
    this.posX = posX;
    this.posY = posY;
    this.size = size;
    this.textHeight = size/10;
    // push changes to buttons
    for (int i=0; i<buttons.size (); i++) {
      // each space allocated to the buttons will have 80% of actual button and 20% of space around
      float button_size = (size/nbButtons) * 4/5;
      // X position depends on button number, Y position makes room for the question
      float buttonX = i * (size/buttons.size()) + posX;
      float buttonY = posY + textHeight*1.5;
      // set pos/size
      buttons.get(i).move(buttonX, buttonY, button_size);
    }
  }
}

