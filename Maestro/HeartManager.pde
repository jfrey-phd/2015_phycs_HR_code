
// will compute HR
// read network host/port from config file

class HeartManager implements Trigger {

  // current HR
  private int HR = 70;

  // read TCP inputs
  private TCPClientRead readBeats;

  HeartManager() {
    // give pointer to this class for Trigger interface
    readBeats = new TCPClientRead(beatIP, beatPort, this);
  }

  // update TCP stream, compute HR
  public void update() {
    readBeats.update();
  }

  // pulse received
  private void beat() {
    println("Someone has pulsed! t=" + millis());
  }

  // trigger interface: stimulus received, we reveice int code of hexa code of labels...
  public void sendMes(String code) {
    // OVTK_GDF_Beep is our code for beats!
    if (code.equals("OVTK_GDF_Beep")) {
      beat();
    }
    else {
      println("Unknown code: [" + code + "] -- size: " + code.length() + ", time: " + millis());
    }
  }
}

