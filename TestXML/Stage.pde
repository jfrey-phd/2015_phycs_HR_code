
// handle info about what's currently going on during the XP
// TODO: could do better with inheritance

class Stage {
  // 0: title
  // 1: xp
  private int type = -1;



  // for screen
  private String label = "";

  // for XP
  private int nbSentences = -1;
  private int nbSameValence = -1;

  // constructor for a screen
  Stage(String label) {
    type = 0;
    this.label = label;
  }

  // constructor for xp
  Stage(int nbSentences, int nbSameValence) {
    type = 1;
    this.nbSentences = nbSentences;
    this.nbSameValence = nbSameValence;
  }
}
