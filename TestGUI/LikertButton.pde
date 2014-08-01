

class LikertButton {
  private PShape button;
  private String label;
  float posX, posY, size;
  // space between button and label
  private float margin;
  // vertical space allocated for text
  private float TEXT_HEIGHT = 20;

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
    button.setStroke(color(155));
    button.setStrokeWeight(4);
    button.setFill(color(50));
  }

  public void draw() {
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
}

