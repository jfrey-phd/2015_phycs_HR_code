int WINDOW_X = 1000;
int WINDOW_Y = 1000;

LikertScale lik, lik2;

void setup() {
  // using 2D backend as we won't venture in 3D realm
  size(WINDOW_X, WINDOW_Y, P2D);
  lik = new LikertScale("Super question?", 5, 30, 30, 500);

  lik2 = new LikertScale("Super question is back?", 3, 30, 400, 700);
}

void draw() {
  // reset display
  background(128);
  //text("nst", 400, 400);
  // draw likert scale
  lik.draw();
  lik2.draw();
}

// through LikertScale, will recursively inform buttons of the events
void mousePressed() {
  lik.sendMousePress(true);
  lik2.sendMousePress(true);
}

// through LikertScale, will recursively inform buttons of the events, and notify if one is selcted
void mouseReleased() {
  lik.sendMousePress(false);
  if(lik.getClickedButton() >= 0) {
    println("Likert clicked!");
  }
  lik2.sendMousePress(false);
}

