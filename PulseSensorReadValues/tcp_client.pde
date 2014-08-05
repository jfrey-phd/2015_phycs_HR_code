import processing.net.*;

// TCP client for openvibe stimulations events
Client ov_TCPclient;
// if connection is lost, will wait before tying to reco
float TCPRetryDelay = 2;
// time since last connection attempt
long TCPlastAttempt = 0;

// in case a code is split between several network buffer
String broken_msg = "";

// if connection fail, will try again and again every xx seconds
void init_TCP()
{
  System.out.println( "Will connect to: " + IP + ":" + Port);
  ov_TCPclient = new Client(this, IP, Port);
  if (ov_TCPclient.active()) {
    System.out.println( "Connected!");
  } 
  else {
    // can't use try/catch with processing layer, use status 
    System.out.println( "Connection failed, will try again in " + TCPRetryDelay + "s.");
    TCPlastAttempt = millis();
  }
}

// listen to data coming from server. Special processing done to ensure we got complete commands
// NB: suppose that "\n" terminate each command, behavior not guaranteed if the command becomes too lengthy...
// if connection is broken, will try again to reco every TCPRetryDelay seconds
void listen_TCP() 
{
  // if connection inactive, try to reco after TCPRetryDelay has been reached
  // FIXME: another way than creating a client? No reco in processing?
  if (!ov_TCPclient .active() && millis() - TCPlastAttempt > TCPRetryDelay * 1000) {
    System.out.println( "Trying to reconnect...");
    ov_TCPclient = new Client(this, IP, Port);
    TCPlastAttempt = millis();
    if (ov_TCPclient.active()) {
      System.out.println( "Connected!");
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
    if (!input.substring(input.length() - 1).equals("\n")) {
      println("============== Error ===============");
      mes_OK = false;
    }
    // If we only had on code which is broken, add it to buffer and lea
    String str[]=input.split("\n");

    // stop before last, because message can be incomplete
    for (int i=0; i<str.length - 1; i++) {
      if (print_serial) {
        println("received: [" + str[i] + "]");
      }
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
      if (print_serial) {
        println("received: [" + last + "]");
      }
      trigger(last);
      // if the last chunk is ok, we don't have any pending broken message
      broken_msg="";
    }

    println("--");
  }
}

// the equivalent of keyPressed() from main program
// we reveice int code of hexa code of labels...
void trigger(String code) {
  // if we want to receive special code...
  if (code.equals("special")) {
    ;
  }
  else {
    Sensor = int(trim(code));
    if (print_serial) {
      println("[" + code + "] -- size: " + code.length() + ", time: " + millis());
    }
  }
}

