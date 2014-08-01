int WINDOW_X = 1000;
int WINDOW_Y = 1000;

LikertScale lik, lik2;

void setup() {
  // using 2D backend as we won't venture in 3D realm
  size(WINDOW_X, WINDOW_Y, P2D);
  lik = new LikertScale("Super question?", 5, 30, 30, 500, true);

  lik2 = new LikertScale("Super question is back?", 3, 30, 400, 700, false);
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
  // won't send new event/take care of click if disabled
  if (!lik.isDisabled()) {
    lik.sendMousePress(false);
    if (lik.getClickedButton() >= 0) {
      println("Likert clicked!");
    }
  }

  // not very good if not "disable_on_click" -- once clicked, will trigger event for every click everywhere 
  if (!lik2.isDisabled()) {
    lik2.sendMousePress(false);
    if (lik2.getClickedButton() >= 0) {
      println("Likert2 clicked!");
    }
  }
}

