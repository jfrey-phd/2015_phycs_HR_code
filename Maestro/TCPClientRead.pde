import processing.net.*;

// will connect to a TCP server, listen for data (strings terminated by '\n') call a Trigger interface for events
// if connection fail, will try again and again every xx seconds
// NB: do not write nothing
// WARNING: if a null Trigger interface is passed, will do nothing

public class TCPClientRead {

  // TCP client for openvibe stimulations events
  private Client ov_TCPclient;
  // IP/port info
  private String IP = "127.0.0.1";
  private int Port = 11000;
  // String used to as terminal character while sending messages
  private final String STIM_SEPARATOR = "\n";

  // if connection is lost, will wait before tying to reco (in ms)
  private final float TCP_RETRY_DELAY = 2000;
  // time since last connection attempt
  private long TCPlastAttempt = 0;

  // in case a code is split between several network buffer
  private String broken_msg = "";

  // Who's method to call when we got a message?
  Trigger trig;

  // need a pointer to a Trigger interface for sending strings
  TCPClientRead(String IP, int Port, Trigger trig)
  {
    this.IP = IP;
    this.Port = Port;
    this.trig = trig;
    // tries to connect already
    reco();
  }

  // Connect/reconnect
  private void reco() {
    println( "Will connect to: " + IP + ":" + Port);
    // use PApplet pointer of outer class to create client
    try {
      ov_TCPclient = new ClientTaciturne(Maestro.this, IP, Port);
    }
    // we'll mostly catch NullPointer if socket failed in ClientTaciturne
    catch (Exception e) {
      println("Couldn't create ClientTaciturne, exception: " + e);
    }

    // check state    
    if (ov_TCPclient != null && ov_TCPclient.active()) {
      println( "Connected!");
    } 
    else {
      // can't use try/catch with processing layer, use status 
      println( "Connection failed, will try again in " + TCP_RETRY_DELAY + "ms.");
    }
    TCPlastAttempt = millis();
  }

  // listen to data coming from server. Special processing done to ensure we got complete commands
  // NB: suppose that "\n" terminate each command, behavior not guaranteed if the command becomes too lengthy...
  // if connection is broken, will try again to reco every TCP_RETRY_DELAY seconds
  public void update() 
  {
    // if connection is inactive, try to reco after TCPRetryDelay has been reached
    // TODO: another way than creating a client? No reco in processing?
    if ( 
    (ov_TCPclient == null  || !ov_TCPclient.active()) // object not created or deco happend
    && millis() - TCPlastAttempt > TCP_RETRY_DELAY // and times up
    ) {
      reco();
    }

    // Receive data from server
    if (ov_TCPclient != null && ov_TCPclient.available() > 0) {
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
      // if message is broken, then save it in the right buffer (won't lost data if one code is split across several "packets", because buffer has already be concatenated to input_message)
      if (!mes_OK) {
        broken_msg = last;
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

  // will pass message to Trigger if set
  private void trigger(String code) {
    if (trig != null) {
      trig.sendMes(code);
    }
  }
}

