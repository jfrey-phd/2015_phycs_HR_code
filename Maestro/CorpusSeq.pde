
// A corpus of type SEQUENTIAL, using a fairy tale from http://www.momes.net/histoiresillustrees/contesdemontagne/noelanimaux.html and data from http://www.info.univ-tours.fr/~antoine/parole_publique/TESTACCORD/index.html

public class CorpusSeq extends Corpus {

  // Careful, headers have to be id/valence/sd/text
  private Table testaccord;
  // which sentence we draw
  private int currentRow = -1;  

  CorpusSeq() {
    super(Type.SEQUENTIAL);
    // load estaccord_emotion_contexte, got headers, fields separated by tabs
    testaccord = loadTable("testaccord_emotion_contexte.csv", "header, tsv");
    println("Loaded testaccord_emotion, nb rows: " + testaccord.getRowCount());
  }

  // Draw next sentence from corpus and return it
  // a null object is return if there is no more sentence to be fetched.
  public Sentence drawText() {
    // increase our counter
    currentRow++;
    // if we got too far, it's time to give up
    if (currentRow >= testaccord.getRowCount()) {
      println("No more sentence to draw.");
      return null;
    }

    // Fetch data, extract sentence
    TableRow row = testaccord.getRow(currentRow);
    String rowText = row.getString("text");
    float rowValence = row.getFloat("valence");
    float rowSd = row.getFloat("sd");
    println("Retrieved a valence of " + rowValence + " (sd=" + rowSd + "): [" + rowText + "]"); 

    // create and retern sentence
    // NB: valence set to 0 but none asked, really
    return new Sentence(type, rowValence, 0, rowText);
  }

  // to please interface -- should not be called within this type!
  public Sentence drawText(int valence) {
    println("Warning: drawText(valence) called with a Corpus of type " + type + ", will choose next sentence.");
    return drawText();
  }
}

