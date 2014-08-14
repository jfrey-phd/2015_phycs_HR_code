
// A corpus of type SEQUENTIAL, using "soir95" database

public class CorpusSeq extends Corpus {

  CorpusSeq() {
    super(Type.SEQUENTIAL);
  }

  public Sentence drawText() {
    // create and retern sentence
    return new Sentence(type, 0, 0, "Next please!");
  }


  // to please interface -- should not be called within this type!
  public Sentence drawText(int valence) {
    println("Warning: drawText(valence) called with a Corpus of type " + type + ", will choose next sentence.");
    return drawText();
  }
}

