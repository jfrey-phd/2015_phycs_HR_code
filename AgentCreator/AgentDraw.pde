
BodyPart head, eyes, mouth, heart;

void AgentDraw_setup() {
  // Create and position different parts
  head = new BodyPart(Body.Type.HEAD, Body.Genre.MALE);
  head.setPos(0, 0);
  // For eyes we got also some variability
  eyes = new BodyPart(Body.Type.EYES, Body.Genre.MALE);
  eyes.setPos(200, 75);
  eyes.setBPM(10);
  eyes.setBPMVariability(5);

  mouth = new BodyPart(Body.Type.MOUTH, Body.Genre.MALE);
  mouth.setPos(150, 475);

  heart = new BodyPart(Body.Type.HEART, Body.Genre.BOTH); 
  heart.setPos(600, 600);
  heart.setBPM(60);
  heart.setAnimationSpeed(45);
}

void AgentDraw_draw() {

  // animate mouth if needed
  if (isSpeaking()) {
    mouth.animate();
  }

  head.draw();
  eyes.draw();
  mouth.draw();
  heart.draw();
}

