
// create a clickable button with a label beneath

class LikertButton {
  // the actual shape of the button
  private PShape button;

  // label associated
  private String label;
  // ID for passing back information
  private int ID;
  // won't change after click if true
  private boolean disable_on_click;
  // is button enable or not
  private boolean disabled = false;

  // position and size
  float posX, posY, size;
  // space between button and label
  private float margin;
  // vertical space allocated for text
  private float TEXT_HEIGHT = 20;

  // status of mouse pressed/click
  private boolean pressed = false;
  private boolean clicked = false;

  // colors data
  private final int REST_COLOR = 75;
  private final int STROKE_COLOR = 155;
  private final int HOVER_COLOR = 200;
  private final int PRESS_COLOR = 255;
  private final int CLICK_COLOR = 0;

  // current selected color of the button
  private int current_color_fill = REST_COLOR;
  private int current_color_stroke = STROKE_COLOR;

  // on creation, set label, ID, position, and if button should stop responding to event once clicked
  LikertButton(String label, int ID, float posX, float posY, float size, boolean disable_on_click) {
    this.label = label;
    this.posX=posX;
    this.posY=posY;
    this.size=size;
    this.disable_on_click = disable_on_click;
    println(this);
    // margin proportionnal to size: 20%
    margin = size*1/5;
    // the shape of our button is a square
    button =  createShape(RECT, 0, 0, size, size);
    // set default outline 
    button.setStrokeWeight(4);
  }

  // returns true if the mouse is on the button
  // update clicked status at the same time (handy since could be polled by draw() or by mouse event)
  public boolean isMouseHover() {
    boolean isHover =  mouseX > posX && mouseX < posX+size && 
      mouseY > posY && mouseY < posY+size;
    // if not hovering, then a previous click, if any, is useless
    if (!isHover) {
      pressed = false;
    }
    return isHover;
  }


  // update color, unless disable
  // NB: because in this case no update is done, if disable_on_click is set,  setClicked() is the only other place where color is touch
  private void updateColor() {
    // if clicked and should be disabled, colors won't change anymore
    if (disabled) {
      return;
    }

    // special highlight if mouse over the button or, even better, if a click occurred
    if (isMouseHover()) {
      if (pressed) {
        current_color_fill=PRESS_COLOR;
      }
      else {
        current_color_fill=HOVER_COLOR;
      }
    }
    // if button has been clicked, the color is more here for debug
    else if (clicked) {
      current_color_fill=CLICK_COLOR;
    } 
    // no particular highlight
    else {
      current_color_fill=REST_COLOR;
    }
  }

  // render the button + label
  // alpha: set transparency -- for fading for example
  public void draw(int alpha) {
    // fillin depends on mouse state
    updateColor();
    // set default colors
    button.setFill(color(current_color_fill, alpha));
    button.setStroke(color(current_color_stroke, alpha));

    shape(button, posX, posY);
    // put black text on the center bottom, with a margin
    fill(0, alpha);
    textAlign(CENTER, TOP);
    textSize(TEXT_HEIGHT);
    text(label, posX+size/2, posY+size+margin);
  }

  // render the button + label
  public void draw() {
    draw(255);
  }

  public String toString() {
    return "Button" + ID + ", label [" + label + "], posX [" + posX + "], posY [" + posY + "], size [" + size + "]";
  }

  // informs the button that a press occurred (true) or not (false)
  // NB: won't do anything if disabled
  public void setPressed(boolean flag) {
    // disabled once for all
    if (disabled) {
      return;
    }

    pressed = flag;
    if (flag) {
      println(this + " pressed!");
    }
  }

  // inform the button it has been clicked (pressed and released while mouse over, checked by LikertScale)
  // NB: will disable button if clicked &&_disable_on_click
  public void setClicked() {
    // if disable, no more use
    if (disabled) {
      return;
    }
    clicked= true;
    println(this + " clicked!");
    // no update will occurs if disable_on_click, we have to change once the color here
    current_color_fill=CLICK_COLOR;
    // disable once for all
    if (clicked && disable_on_click) {
      disabled = true;
    }
  }

  // has a press previously occurred?
  public boolean isPressed() {
    return pressed;
  }

  // this is the one
  public boolean isClicked() {
    return clicked;
  }

  // return ID
  public int getID() {
    return ID;
  }

  public void disable() {
    disabled = true;
  }
}

