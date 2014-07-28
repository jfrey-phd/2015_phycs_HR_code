
// at the moment our agent is disassembled
PShape head, eye, mouth;

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
  eye.resetMatrix();
  mouth.resetMatrix();
  float eye_scale = 1.0;
  if (eye_scale < 0.1)
    eye_scale = 0.1;
  if (eye_scale > 1)
    eye_scale = 1;
  eye.scale(1.0, eye_scale);
  mouth.scale(1.0, eye_scale);

  // draw every part
  shape(head, 0, 0);
  // two eyes...
  shape(eye, 400, 75);
  shape(eye, 150, 75);
  shape(mouth, 150, 475);
}

