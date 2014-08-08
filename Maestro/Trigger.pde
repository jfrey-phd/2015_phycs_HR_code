
// interfaces for passing message between classes (send strings for TCP/TTS and so on)

public interface Trigger {
  // send a message, several different types available
  public void sendMes(String mes);
  //public void sendMes(int mes);

  // make an action (no argument in here)
  //public void trigAction();
}

