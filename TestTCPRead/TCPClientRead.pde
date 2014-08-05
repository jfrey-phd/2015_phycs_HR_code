import processing.net.*;

// will connect to a TCP server, listen for data (strings terminated by '\n') and trigger events
// if connection fail, will try again and again every xx seconds
// NB: do not write nothing

public class TCPClientRead {

  // TCP client for openvibe stimulations events
  private Client ov_TCPclient;
  // IP/port info
  private String IP = "127.0.0.1";
  private int Port = 11000;
  // String used to as terminal character while sending messages
  private final String STIM_SEPARATOR = "\n";
  // pointer to main prog in order to create new Client here... and to inform about beats
  // TODO: improve encapsulation
  private TestTCPRead mainProg;

  // if connection is lost, will wait before tying to reco (in ms)
  private final float TCP_RETRY_DELAY = 2000;
  // time since last connection attempt
  private long TCPlastAttempt = 0;

  // in case a code is split between several network buffer
  private String broken_msg = "";

  // need a pointer to PApplet because will have to create Client by itself
  TCPClientRead(TestTCPRead mainProg, String IP, int Port)
  {
    this.mainProg = mainProg;
    this.IP = IP;
    this.Port = Port;
    println( "Will connect to: " + IP + ":" + Port);
    ov_TCPclient = new Client(mainProg, IP, Port);
    if (ov_TCPclient.active()) {
      println( "Connected!");
    } 
    else {
      // can't use try/catch with processing layer, use status 
      println( "Connection failed, will try again in " + TCP_RETRY_DELAY + "ms.");
      TCPlastAttempt = millis();
    }
  }

  // listen to data coming from server. Special processing done to ensure we got complete commands
  // NB: suppose that "\n" terminate each command, behavior not guaranteed if the command becomes too lengthy...
  // if connection is broken, will try again to reco every TCP_RETRY_DELAY seconds
  public void update() 
  {
    // if connection inactive, try to reco after TCPRetryDelay has been reached
    // FIXME: another way than creating a client? No reco in processing?
    if (!ov_TCPclient .active() && millis() - TCPlastAttempt > TCP_RETRY_DELAY) {
      println( "Trying to reconnect...");
      ov_TCPclient = new Client(mainProg, IP, Port);
      TCPlastAttempt = millis();
      if (ov_TCPclient.active()) {
        println( "Connected!");
      }
    }

    // Receive data from server
    if (ov_TCPclient.available() > 0) {
      // debug
      if (!broken_msg.equals("")) {
        println("====concatenating [" + broken_msg + "]");
      }
      // flag to check for carriage return
      boolean mes_OK = true;
      // Retrieve data, each line should correspond to one stimulation
      // append eventual partial message from a previous broken code
      String input = broken_msg+ov_TCPclient.readString();
      // if not terminated by line return, there's a problem
      if (!input.substring(input.length() - 1).equals(STIM_SEPARATOR)) {
        println("============== Error ===============");
        mes_OK = false;
      }
      // If we only had on code which is broken, add it to buffer and lea
      String str[]=input.split(STIM_SEPARATOR);

      // stop before last, because message can be incomplete
      for (int i=0; i<str.length - 1; i++) {
        // see what it can do...
        trigger(str[i]);
        // if we are in this loop (at least one code ending with line return), then last broken message has been sent
        broken_msg="";
      }
      // last code
      String last = str[str.length - 1];
      // if message is broken, then save it in the right buffer (which could hold already something if the same code is split across several "packets")
      if (!mes_OK) {
        broken_msg += last;
        println("====partial code: " +  broken_msg);
      }
      // everything ok, treat the same the last element
      else {
        trigger(last);
        // if the last chunk is ok, we don't have any pending broken message
        broken_msg="";
      }

      //println("--");
    }
  }

  // the equivalent of keyPressed() from main program
  // we reveice int code of hexa code of labels...
  void trigger(String code) {
    // OVTK_GDF_Beep is our code for beats!
    if (code.equals("OVTK_GDF_Beep")) {
      // inform main prog
      mainProg.beat();
    }
    else {
      println("Unknown code: [" + code + "] -- size: " + code.length() + ", time: " + millis());
    }
  }
}

