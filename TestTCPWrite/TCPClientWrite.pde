import processing.net.*;
import java.util.Stack;

// will connect to a TCP server, wirte stims (strings terminated by '\n')
// if connection fail, will try again and again every xx seconds
// message not sent are enqueued
// NB: do not listen

public class TCPClientWrite {

  // TCP client for openvibe stimulations events
  private Client ov_TCPclient;
  // IP/port info
  String IP = "127.0.0.1";
  int Port = 11000;
  // pointer to main prog in order to create new Client here
  // TODO: improve encapsulation
  PApplet mainProg;

  // pending messages
  private Stack<String> mesStack;

  // if connection is lost, will wait before tying to reco (in ms)
  private final float TCP_RETRY_DELAY = 2000;
  // time since last connection attempt
  private long TCPlastAttempt = 0;

  // need a pointer to PApplet because will have to create Client by itself
  TCPClientWrite(PApplet mainProg, String IP, int Port)
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
    // new stack for our messages if something goes wrong
    mesStack = new Stack<String>();
  }

  // try to reconnect if connection is broken
  // send pending message as soon as possible
  public void update() 
  {
    // if connection inactive, try to reco after TCPRetryDelay has been reached
    // FIXME: another way than creating a client? No reco in processing?
    if (!ov_TCPclient.active() && millis() - TCPlastAttempt > TCP_RETRY_DELAY) {
      println( "Trying to reconnect...");
      ov_TCPclient = new Client(mainProg, IP, Port);
      TCPlastAttempt = millis();
      if (ov_TCPclient.active()) {
        println( "Connected!");
      }
    }

    // try to send messages in queue if connection is active
    if (!mesStack.empty() && ov_TCPclient.active()) {
      println("Time to free stack.");
      while (!mesStack.empty ()) {
        println(mesStack.size() + " messages pending");
        // get ref to oldest message
        String heap = mesStack.peek();
        // if we manage to send it now, remove it for good
        if (writeOrQueue(heap, false)) {
          mesStack.pop();
        }
        // no need to try furthermore if an error occured
        else {
          println("Faieled to send pending message.");
          break;
        }
      }
    }
  }

  // write stim code to socket, enqueue if can't do that
  // enqueue: adds message to stack if true (we do not want to push a message already in the stack that we're trying to re-send)
  // return true if message sent
  private boolean writeOrQueue(String stimCode, boolean enqueue) {
    // has me message gone through?
    boolean sent = false;

    println("Try to send: " + stimCode);

    // if connection still active, give it a shot
    if (ov_TCPclient.active()) {
      // double check
      try {
        ov_TCPclient.write(stimCode);
        // if we got here, it's all good
        sent = true;
      }
      catch (Exception e) {
        println("Error while sending message");
      }
    }
    // if connection not active, do not bother to send message
    else {
      println("Connection disabled");
    }

    // time to check if we need to add message to stack
    if (!sent && enqueue) {
      mesStack.push(stimCode);
      println("Message adedd to stack, now " + mesStack.size() + " pending.");
    }

    return sent;
  }

  // return true if message sent right away
  // false if put in stack
  // WARNING: do not send message which contain '\n', will split stim in the end
  public boolean write(String stimCode) {
    // we don't want to loose messages from clients
    return writeOrQueue(stimCode, true);
  }
}

