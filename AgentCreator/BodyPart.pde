

public class BodyPart {

  private Body.Type type;
  private Body.Genre genre;
  // use an array of frames for animations
  private ArrayList<PShape> frames;
  private int current_frame = 0;

  // greater than 0, will trigger animations (if any exists)
  // animation will be automatically played BPM times per minutes
  private int BPM = 0;
  // if != 0, a noise will be added to BPM to avoid too constant beats
  // NB: careful if too close to BPM : could lead to very slow beat
  private float BPM_variability = 0;
  // variability is computed once per beat -- otherwise mixes up too much computations, small BPM more likely to appear
  private float next_BPM = BPM;
  // flag to start animation on next draw
  private boolean start_anim = false;

  // the time in ms between each frame of the animation
  private float animation_speed = 100;
  // when last animation has been triggered
  private int last_beat = 0;
  // during animation, when last frame occured
  private int last_keyframe = 0;

  // in (0,0) coordinates by default
  private float x = 0;
  private float y = 0;

  // set type and load model
  BodyPart(Body.Type type, Body.Genre genre) {
    this.type = type;
    this.genre = genre;
    frames = new ArrayList();
    loadModel();
    // init animation variables
    last_beat = millis();
  }

  // load svg on creation
  private void loadModel() {
    PShape img;
    // build filename step by step
    String filename = Body.getTypeName(type) +  "_" + Body.getGenreName(genre) + "_1.svg";
    // load file
    println("Loading: " +  filename);
    img = loadShape(filename);
    println(img.getChildCount() + " children found.");
    // Counting the number of frames -- each layer should be named "Layer X"
    int nbFrames = 0;
    PShape frame = null;
    // will loop and push to "frames" as long as finds layers
    do {
      String layerName = "layer" + Integer.toString(nbFrames+1);
      //println("Look for " + layerName);
      frame = img.findChild(layerName);
      if (frame != null) {
        frames.add(frame);
        nbFrames++;
      }
    } 
    while (frame != null);
    println("Found " + nbFrames + " frames.");
  }

  // render to screen the current frame
  public void draw() {
    // quit immidiatly if there's nothing to show
    if (frames.size() == 0) {
      return;
    }

    // check if new beat must be initiated
    int tick = millis();

    if (next_BPM > 0 && tick > last_beat + 60000/next_BPM) {
      start_anim = true;
      last_beat = tick;
      // adjust BPM with variability
      next_BPM = BPM + random(-BPM_variability, BPM_variability);
      // avoid blocking if poor choice of variability leads to death
      if (next_BPM < 0) {
        next_BPM = BPM;
      }
      println("Next BPM for " + this + ": " + next_BPM );
    }

    if (
    // if an animation should start and is not already taking place...
    (start_anim && current_frame == 0)
      // OR if an animation is already taking place and it is time so show a new frame...
    || (current_frame != 0 && tick > last_keyframe + animation_speed)
      )
      // THEN we go for a cartoon
    {
      start_anim = false;
      // next frame... but don't go too far
      current_frame++;
      if (current_frame >= frames.size()) {
        current_frame = 0;
      }
      // reset timestamp for keyframe
      last_keyframe = tick;
    }

    // we just need to retrieve current frame and put it in the right place
    PShape frame = frames.get(current_frame);
    shape(frame, x, y);
  }

  // set coordinates in screen space
  public void setPos(float x, float y) {
    this.x = x;
    this.y = y;
  }

  // set BPM
  // initiate animations if > 0, stop them if == 0
  public void setBPM(int BPM) {
    this.BPM = BPM;
    next_BPM = BPM;
  }

  // setter for BPM variability (noisy BPM computed in draw())
  public void setBPMVariability(int variability) {
    this.BPM_variability = variability;
  }

  // a hint of true java under the hood
  public String toString() {
    return Body.getTypeName(type);
  }

  // start a new animation
  // return false if it is not possible -- already ocurring or no more than 1 frame
  public boolean animate() {
    if (current_frame != 0 || frames.size() < 2) {
      return false;
    }
    return start_anim = true;
  }

  // setter for animation speed, time in ms between two frames
  public void setAnimationSpeed(float speed) {
    animation_speed = speed;
  }
};

