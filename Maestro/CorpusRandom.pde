
// A corpus of type RANDOM, using "soir95" database

public class CorpusRandom extends Corpus {

  // corpus from Bestgen 2004
  // Careful, headers have to be id/random/valence/sd/text
  private Table soir95;
  // 3 lists of indexes for 3 different type of valence contained in soir95
  private IntList soir95_sad;
  private IntList soir95_neutral;
  private IntList soir95_happy;

  // filename: csv file holding corpus (take care of format)
  CorpusRandom(String filename) {
    // we are the random type
    super(Type.RANDOM);
    println("Loading corpus: " + filename);
    // load soir95, got headers, fields separated by tabs
    soir95 = loadTable(filename, "header, tsv");
    println("Loaded soir95 [" + filename + "], nb rows: " + soir95.getRowCount());

    // split corpus depending on valence
    soir95_sad = new IntList();
    soir95_neutral = new IntList();
    soir95_happy = new IntList();
    // TODO: ugly way to do it, can't simply select values with operators??
    for (int i = 0; i < soir95.getRowCount (); i++) {
      TableRow row = soir95.getRow(i);
      float val = row.getFloat("valence");
      // in [-3 ; -1[ sad
      if (val < -1) {
        soir95_sad.append(i);
      }
      // in ]1 ; 3] happy
      else if (val > 1) {
        soir95_happy.append(i);
      }
      // in [-1 ; 1] neutral
      else {
        soir95_neutral.append(i);
      }
    }
    println("There is " +  soir95_sad.size() + " sad stories, " + soir95_happy.size() + " happy ones and " + soir95_neutral.size() + " not that much exciting.");
  }

  // randomly select an item, remove it from the list and return the corresponding row from main table (null if list is empty)
  private TableRow randomPop(IntList  list) {
    // randomly select a row
    int nbItems = list.size();
    println("nb items left: " +  nbItems);
    if (nbItems == 0) {
      return null;
    }
    int itemID = round(random(0, nbItems-1));
    int rowID = list.get(itemID);
    println("random id: " + itemID + ", corresponds to row: " + rowID);
    TableRow row = soir95.getRow(rowID);
    // remove from source (so we can't have duplicates) and return
    list.remove(itemID);
    return row;
  }

  // retrieve a random sentence from corpus (returned strings being removed from it and associated info)
  // valence: -1 for negative, 0 for neutral, 1 for positive (see implementation for mapping)
  // return a sentence corresponding to valence, null in none found
  public Sentence drawText(int valence) {
    println("Is gonna check for a valence coded as: " + valence);
    // will hold the raw we are gonna draw
    TableRow row = null;
    switch(valence) {
    case -1:
      row = randomPop(soir95_sad);
      break;
    case 1:
      row = randomPop(soir95_happy);
      break;
    case 0:
      row = randomPop(soir95_neutral);
      break;
    }

    // if we were too greedy we have nothing to return
    if (row == null) {
      println("Error: empty row");
      return null;
    }

    // Extract the sentence and associated info
    String rowText = row.getString("text");
    float rowValence = row.getFloat("valence");
    float rowSd = row.getFloat("sd");
    println("Retrieved a valence of " + rowValence + " (sd=" + rowSd + "): [" + rowText + "]"); 

    // create and return sentence
    return new Sentence(type, rowValence, valence, rowText);
  }

  // to please interface -- should not be called within this type!
  public Sentence drawText() {
    println("Warning: drawText() called with a Corpus of type " + type + ", will choose valence 0.");
    return drawText(0);
  }
}

