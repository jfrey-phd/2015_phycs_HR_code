
// create a clickable button with a label beneath

class LikertButton {
  private PShape button;
  private String label;
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

  // on creation, set label and position
  LikertButton(String label, float posX, float posY, float size) {
    this.label = label;
    this.posX=posX;
    this.posY=posY;
    this.size=size;
    println(this);
    // margin proportionnal to size: 20%
    margin = size*1/5;
    // the shape of our button is a square
    button =  createShape(RECT, 0, 0, size, size);
    // set default colors
    button.setStroke(color(STROKE_COLOR));
    button.setStrokeWeight(4);
    button.setFill(color(REST_COLOR));
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


  // update color
  private void updateColor() {
    // special highlight if mouse over the button or, even better, if a click occurred
    if (isMouseHover()) {
      if (pressed) {
        button.setFill(color(PRESS_COLOR));
      }
      else {
        button.setFill(color(HOVER_COLOR));
      }
    }
    // if button has been clicked, the color is more here for debug
    else if (clicked) {
      button.setFill(color(CLICK_COLOR));
    } 
    // no particular highlight
    else {
      button.setFill(color(REST_COLOR));
    }
  }

  // render the button + label
  public void draw() {
    // fillin depends on mouse state
    updateColor();
    shape(button, posX, posY);
    // put black text on the center bottom, with a margin
    fill(0);
    textAlign(CENTER, TOP);
    textSize(TEXT_HEIGHT);
    text(label, posX+size/2, posY+size+margin);
  }

  public String toString() {
    return "Button, label [" + label + "], posX [" + posX + "], posY [" + posY + "], size [" + size + "]";
  }

  // informs the button that a press occurred (true) or not (false)
  public void setPressed(boolean flag) {
    pressed = flag;
    if (flag) {
      println(this + " pressed!");
    }
  }

  // inform the button it has been clicked (pressed and released while mouse over, checked by LikertScale)
  public void setClicked() {
    clicked= true;
    println(this + " clicked!");
  }

  // has a press previously occurred?
  public boolean isPressed() {
    return pressed;
  }
}

