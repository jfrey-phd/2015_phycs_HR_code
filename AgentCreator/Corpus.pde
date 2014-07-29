
// corpus from Bestgen 2004
// Careful, headers have to be id/random/valence/sd/text
Table soir95;
Table soir95_sad;
Table soir95_neutral;
Table soir95_happy;

// create an empty table with soir95 headers
// TODO: clone them from soir95
Table Corpus_createEmptyCorpus() {
  Table corpus = new Table();
  // cf csv file for order
  corpus.addColumn("id");
  corpus.addColumn("random");
  corpus.addColumn("valence");
  corpus.addColumn("sd");
  corpus.addColumn("text");
  return corpus;
}

void Corpus_setup() {
  // load soir95, got headers, fields separated by tabs
  soir95 = loadTable("soir95_header.csv", "header, tsv");
  println("Loaded soir95, nb rows: " + soir95.getRowCount());

  // split corpus depending on valence
  soir95_sad = Corpus_createEmptyCorpus();
  soir95_neutral = Corpus_createEmptyCorpus();
  soir95_happy = Corpus_createEmptyCorpus();
  // FIXME: ugly way to do it, can't simply select values with operators??
  for (TableRow row : soir95.rows()) {
    float val = row.getFloat("valence");
    // in [-3 ; -1[ sad
    if (val < -1) {
      soir95_sad.addRow(row);
    }
    // in ]1 ; 3] happy
    else if (val > 1) {
      soir95_happy.addRow(row);
    }
    // in [-1 ; 1] neutral
    else {
      soir95_neutral.addRow(row);
    }
  }
  println("There is " +  soir95_sad.getRowCount() + " sad stories, " + soir95_happy.getRowCount() + " happy ones and " + soir95_neutral.getRowCount() + " not that much exciting.");
}

// randomly select one row, remove it from the table and return it (null if table is empty)
// TODO: check that it could retrieve every rows
TableRow Corpus_randomPop(Table table) {
  // randomly select a row
  int nbRows = table.getRowCount();
  println("nb rows left: " +  nbRows);
  if (nbRows == 0) {
    return null;
  }
  int rowID = round(random(0, nbRows-1));
  println("random id: " + rowID);
  TableRow row = table.getRow(rowID);
  // remove from source (so we can't have duplicates) and return
  table.removeRow(rowID);
  return row;
}

// retrieve a random sentence from corpus (returned strings being removed from it)
// valence: -1 for negative, 0 for neutral, 1 for positive (see implementation for mapping)
// return a sentence corresponding to valence, empty in none found
String Corpus_drawText(int valence) {
  println("Is gonna check for a valence coded as: " + valence);
  // will hold the raw we are gonna draw
  TableRow row = null;
  switch(valence) {
  case -1:
    row = Corpus_randomPop(soir95_sad);
    break;
  case 1:
    row = Corpus_randomPop(soir95_happy);
    break;
  case 0:
    row = Corpus_randomPop(soir95_neutral);
    break;
  }

  // if we were too greedy we have nothing to return
  if (row == null) {
    println("Error: empty row");
    return "";
  }

  // Extract the sentence
  String rowText = row.getString("text");
  // And few more infos for debug
  float rowValence = row.getFloat("valence");
  float rowSd = row.getFloat("sd");

  println("Retrieved a valence of " + rowValence + " (sd=" + rowSd + "): [" + rowText + "]"); 

  return rowText;
}

