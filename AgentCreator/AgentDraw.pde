
// TODO: proper classes instead of bunch of functions

// remember animation state for the eye
boolean eye_blinking = false; // currently blinking
boolean eye_closing = false; // eyes are closing
float eye_scale = 1.0; // current Y scale
float eye_BPM = 10;
int eye_last_beat = 0;
// if != 0, a noise will be added to BPM to avoid too constant beats
float eye_BPM_variability = 5;
// variability is computed once per beat -- otherwise mixes up too much computations, small BPM more likely to appear
// NB: careful if too close to BPM : could lead to very slow beat
float eye_next_BPM = eye_BPM;

// remember animation state for the mouth
boolean mouth_speaking = false; // currently speaking
boolean mouth_closing = false; // mouth closing
float mouth_scale = 1.0; // current Y scale

// remember animation state for the heart
boolean heart_beating = false; // currently beating
int heart_anim_step = 0; // 1: growing, 2: shrinking, 3: bak to default, 0: resting
float heart_scale = 1.0; // current Y scale
float heart_BPM = 60;
int heart_last_beat = 0; 

void AgentDraw_setup() {
  // load the different parts of the agent
  head = loadShape("head_M_1.svg");
  eye = loadShape("eye_M_1.svg");
  mouth = loadShape("mouth_M_1.svg");
  heart = loadShape("heart.svg");
  heart_last_beat = millis();
  eye_last_beat = millis();
}

void draw_eyes() {
  // check if new beat must be initiated
  int tick = millis();
  if (eye_next_BPM > 0 && tick > eye_last_beat + 60000/eye_next_BPM) {
    eye_blink = true;
    eye_last_beat = tick;
    // adjust BPM with variability
    eye_next_BPM = eye_BPM + random(-eye_BPM_variability, eye_BPM_variability);
    // avoid blocking if poor choice of variability leads to death
    if (eye_next_BPM < 0) {
      eye_next_BPM = eye_BPM;
    }
    println(eye_next_BPM );
  }

  // influence blink speed;
  float anim_step = 0.08;

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
    if (mouth_scale <= 0.5) {
      mouth_scale = 0.5;
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

void draw_heart() {
  // check if new beat must be initiated
  int tick = millis();
  if (heart_BPM > 0 && tick > heart_last_beat + 60000/heart_BPM) {
    heart_animation = true;
    heart_last_beat = tick;
  }

  // the svg is a bit big for a start
  float heart_default_scale = 0.75;

  // influence blink speed;
  float anim_step = 0.05;

  // if a blinks happens and not already blinking, we have initiate scale
  if (heart_animation && !heart_beating) {
    heart_animation = false;
    heart_beating = true;
    heart_anim_step = 1;
    heart_scale = 1;
  }

  // scale according to animation tate
  switch(heart_anim_step) {
    // grows
  case 1:
    heart_scale += anim_step;
    if (heart_scale >= 1.2) {
      heart_scale = 1.2;
      heart_anim_step = 2;
    }
    break;
    // shrinks
  case 2:
    heart_scale -= anim_step;
    if (heart_scale <= 0.8) {
      heart_scale = 0.8;
      heart_anim_step = 3;
    }
    break;
    // back to resting
  case 3:
    heart_scale += anim_step;
    if (heart_scale >= 1) {
      heart_scale = 1;
      heart_anim_step = 0;
      heart_beating = false;
    }
    break;
    // resting
  default:
    break;
  }

  heart.resetMatrix();
  // one for default, one for animation
  heart.scale(heart_default_scale, heart_default_scale);
  heart.scale(heart_scale, heart_scale);

  shapeMode(CENTER);
  shape(heart, 800, 800);
  shapeMode(CORNER);
}

