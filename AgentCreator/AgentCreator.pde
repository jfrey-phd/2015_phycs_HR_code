
// at the moment our agent is disassembled
PShape head, eye, mouth, heart;

// flag to make eye blink
boolean eye_blink = false;
boolean mouth_animation = false;
boolean heart_animation = false;

void setup() {
  // using 2D backend as we won't venture in 3D realm
  size(1000, 1000, P2D);
  smooth();
  // load the different parts of the agent
  head = loadShape("head_M_1.svg");
  eye = loadShape("eye_M_1.svg");
  mouth = loadShape("mouth_M_1.svg");
  heart = loadShape("heart.svg");
}

void draw() {
  // reset display
  background(255);
  // draw every part
  shape(head, 0, 0);
  // deals with blinking also
  draw_eyes();
  draw_mouth();
  draw_heart();
}

// trigger different action for debug
void keyPressed() {
  if (key == 'b') {
    //scale = 1;
    eye_blink = true;
  }
  else if (key == 'm') {
    mouth_animation = true;
  }
  else if (key == 'h') {
    heart_animation = true;
  }
}

