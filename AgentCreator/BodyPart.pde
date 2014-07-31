

public class BodyPart {

  private Body.Type type;
  private Body.Genre genre;
  private PShape img;
  // greater than 0, will trigger animations (if any exists)
  private int BPM = 0;

  private float x;
  private float y;

  BodyPart(Body.Type _type, Body.Genre _genre) {
    type = _type;
    genre = _genre;
    loadModel();
  }

  private void loadModel() {
    // build filename step by step
    String filename = Body.getTypeName(type) +  "_" + Body.getGenreName(genre) + "_1.svg";
    println("Loading: " +  filename);
    img = loadShape(filename);
  }

  public void draw() {
    shape(img, 0, 0);
  }
};

