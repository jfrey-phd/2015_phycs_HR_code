
// abstract class for drawing text from corpus. There is typically two kind of them: random (possible to draw randomely sentences of spetific valence) or sequential (draw one sentence after the other).
// TODO: *two* levels of abstacts: corpus->random/sequential/->actual corpus

public abstract class Corpus {

  // The two types of corpus
  public enum Type {
    // possible to choose valence, sentences returned randomely
    RANDOM, 
    // one sentence after the other (eg: a story)
    SEQUENTIAL, 
    // for setting default values outside corpus
    UNKNOWN
  };

  // Use inner class to limit tabs
  // Holds info about a sentence extracted from corpus
  // TODO: retrieve and use more info for analysis (eg: index, sd)?
  public static class Sentence {
    // from which corpus it comes from
    public final Type corpusType;
    // valence as jugded by originally
    public final float origValence;
    // we make different range compared to origValence
    public final int valence;
    // the sentence itself
    public final String text;

    Sentence(Type corpusType, float origValence, int valence, String text) {
      this.corpusType = corpusType;
      this.origValence = origValence;
      this.valence = valence;
      this.text = text;
    }
  }

  // we get to know the corpus type we're dealing with
  public final Type type;

  // the least children can do is to teach about their type
  Corpus(Type type) {
    this.type = type;
  }

  // RANDOM: retrieve a random sentence from corpus (returned strings being removed from it and associated info)
  // valence: -1 for negative, 0 for neutral, 1 for positive (see implementation for mapping)
  // return a sentence corresponding to valence, null in none found
  // SEQUENTIAL: equivalent to drawText()
  public abstract Sentence drawText(int valence);

  // SEQUENTIAL: retrieve next sentence from corpus (returned strings being removed from it and associated info)
  // return a sentence corresponding to valence, null in none found
  // RANDOM: equivalent to drawText(0);
  public abstract Sentence drawText();
}

