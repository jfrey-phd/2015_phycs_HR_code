
// at the moment our agent is disassembled
PShape head, eye, mouth;

// flag to make eye blink
boolean eye_blink = false;
boolean mouth_animation = false;

// remember animation state for the eye
boolean eye_blinking = false; // currently blinking
boolean eye_closing = false; // eyes are closing
float eye_scale = 1.0; // current Y scale

// remember animation state for the mouth
boolean mouth_speaking = false; // currently speaking
boolean mouth_closing = false; // mouth closing
float mouth_scale = 1.0; // current Y scale

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
  // draw every part
  shape(head, 0, 0);
  // deals with blinking also
  draw_eyes();
  draw_mouth();
}

void draw_eyes() {
  // influence blink speed;
  float anim_step = 0.04;

  // if a blinks happens and not already blinking, we have initiate scale
  if (eye_blink && !eye_blinking) {
    eye_blink = false;
    eye_blinking = true;
    eye_closing = true;
    eye_scale = 1;
  }

  // scale according to blinking state
  if (eye_blinking) {
    // shrinking while closing
    if (eye_closing) {
      eye_scale -= anim_step;
    }
    else {
      eye_scale += anim_step;
    }
    // once we reached a bottom point, opening again
    if (eye_scale <= 0) {
      eye_scale = 0.01;
      eye_closing = false;
    }
    // once opened, finished animation
    if (eye_scale >= 1) {
      eye_scale = 1;
      eye_blinking = false;
    }
  }

  // before drawing, reset transformation to eyes and apply current scale
  eye.resetMatrix();
  eye.scale(1.0, eye_scale);

  // two of the same eye...
  // blinks renders better if they stay centered...
  shapeMode(CENTER);
  shape(eye, 500, 240);
  shape(eye, 250, 240);
  shapeMode(CORNER);
}

void draw_mouth() {
  // influence blink speed;
  float anim_step = 0.08;

  // if a blinks happens and not already blinking, we have initiate scale
  if (mouth_animation && !mouth_speaking) {
    mouth_animation = false;
    mouth_speaking = true;
    mouth_closing = true;
    mouth_scale = 1;
  }

  // scale according to blinking state
  if (mouth_speaking) {
    // shrinking while closing
    if (mouth_closing) {
      mouth_scale -= anim_step;
    }
    else {
      mouth_scale += anim_step;
    }
    // once we reached a bottom point, opening again
    if (mouth_scale <= 0) {
      mouth_scale = 0.01;
      mouth_closing = false;
    }
    // once opened, finished animation
    if (mouth_scale >= 1) {
      mouth_scale = 1;
      mouth_speaking = false;
    }
  }

  // before drawing, reset transformation to eyes and apply current scale
  mouth.resetMatrix();
  mouth.scale(1.0, mouth_scale);

  shape(mouth, 150, 475);
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
  //  else if (key == 'h') {
  //    pulse();
  //  }
}

