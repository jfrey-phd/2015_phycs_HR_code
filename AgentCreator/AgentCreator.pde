
// at the moment our agent is disassembled
PShape head, eye, mouth;

// flag to make eye blink
boolean eye_blink = false;

// remember animation state for the eye
boolean blinking = false; // currently blinking
boolean closing = false; // eyes are closing
float scale = 1.0; // current Y scale

void setup() {
  // using 2D backend as we won't venture in 3D realm
  size(1000, 1000, P2D);
  smooth();
  // load the different parts of the agent
  head = loadShape("head_M_1.svg");
  eye = loadShape("eye_M_1.svg");
  mouth = loadShape("mouth_M_1.svg");
}

void draw() {
  // reset display
  background(255);

  // manual blink and speak
  mouth.resetMatrix();
  float eye_scale = 1.0;
  if (eye_scale < 0.1) {
    eye_scale = 0.1;
  }
  if (eye_scale > 1) {
    eye_scale = 1;
  }

  mouth.scale(1.0, eye_scale);

  // draw every part
  shape(head, 0, 0);
  // deals with blinking also
  draw_eyes();
  shape(mouth, 150, 475);
}

void draw_eyes() {
  // influence blink speed;
  float blink_step = 0.04;

  // if a blinks happens and not already blinking, we have initiate scale
  if (eye_blink && !blinking) {
    eye_blink = false;
    blinking = true;
    closing = true;
    scale = 1;
  }

  // scale according to blinking state
  if (blinking) {
    // shrinking while closing
    if (closing) {
      scale -= blink_step;
    }
    else {
      scale += blink_step;
    }
    // once we reached a bottom point, opening again
    if (scale <= 0) {
      scale = 0.01;
      closing = false;
    }
    // once opened, finished animation
    if (scale >= 1) {
      scale = 1;
      blinking = false;
    }
  }

  // before drawing, reset transformation to eyes and apply current scale
  eye.resetMatrix();
  eye.scale(1.0, scale);

  // two of the same eye...
  shape(eye, 400, 75);
  shape(eye, 150, 75);
}

// trigger different action for debug
void keyPressed() {
  if (key == 'b') {
    //scale = 1;
    eye_blink = true;
  }
  //  else if (key == 'm') {
  //    speak();
  //  }
  //  else if (key == 'h') {
  //    pulse();
  //  }
}

