
// will create an "agent" from different body parts
// NB: the screen space is believed to be 1000x1000
// NB: call Body.setTableParts() beforehand fore randomness
public class Agent {

  // FIXME: public for debug through keyboard
  public BodyPart head, eyes, mouth, heart;
  // Every elemet will be connected to it
  private PShape wholeBody;

  // use to check if mouth animation should be played in update()
  private AgentSpeak tts;


  // Create the different parts -- by default HR is set to medium
  Agent() {
    this(Body.HR.MEDIUM);
  }

  // Create the different parts. HRType: which kind of beat we got for the heart
  // TODO: handle human, tune heart rates
  Agent(Body.HR HRType) {
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

    // Special case for heart: will play a sound with each beat
    heart = new BodyPart(Body.Type.HEART, Body.Genre.BOTH, "beat.wav"); 
    heart.setPos(600, 600);

    // deals with heart rate
    switch(HRType) {
    case LOW:
      heart.setBPM(20);
      break;
    case HIGH:
      heart.setBPM(120);
      break;
      // our human is almost dead at the moment
    case HUMAN:
      heart.setBPM(5);
      break;
      // if not recognized: medium by default
    default:
      println("Unknown HR type: " + HRType + ", set to medium");
    case MEDIUM:
      heart.setBPM(60);
      break;
    }
    heart.setAnimationSpeed(45);

    // time to add every part to the agent
    wholeBody = new PShape();
    wholeBody.addChild(head.getPShape());
    wholeBody.addChild(eyes.getPShape());
    wholeBody.addChild(mouth.getPShape());
    wholeBody.addChild(heart.getPShape());
  }

  // link to an instance of AgentSpeak for mouth animation
  public void setTTS(AgentSpeak tts) {
    this.tts = tts;
  }

  // will call recursively body parts + make mouth animate if speaking
  public void update() {

    // animate mouth
    if (tts != null && tts.isSpeaking()) {
      mouth.animate();
    }

    // every part will update itself the visibility of the right frame if there's an animation to be played
    head.update();
    eyes.update();
    mouth.update();
    heart.update();
  }

  // access to master shape for transformations and drawing
  public PShape getPShape() {
    return wholeBody;
  }
}

