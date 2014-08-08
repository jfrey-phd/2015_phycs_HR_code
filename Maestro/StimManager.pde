
// abstraction for final output of stimulations: TCP or stdout
// need to call update() to make TCP tick (won't bother much CPU if option not set)

public class StimManager implements Trigger {
  // output socket to TCP if enableStimtTCP
  private TCPClientWrite tcpWriter;

  StimManager() {
    // init output socket if needed
    if (enableStimtTCP) {
      tcpWriter = new TCPClientWrite(Maestro.this, stimIP, stimPort);
    }
  }

  // update tcpWriter stream if applicable
  public void update() {
    if (enableStimtTCP) {
      tcpWriter.update();
    }
  }

  // Trigger interface, chooses the right stream
  public void sendMes(String mes) {
    // init output socket if needed
    if (enableStimtTCP) {
      tcpWriter.write(mes);
    }
    else {
      println(mes);
    }
  }
}
