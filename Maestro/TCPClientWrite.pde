import processing.net.*;
import java.util.Queue;
import java.util.LinkedList;

// will connect to a TCP server, wirte stims (strings terminated by '\n')
// if connection fail, will try again and again every xx seconds
// message not sent are enqueued
// NB: do not listen

// FIXME: factorize with TCPClientRead

public class TCPClientWrite {

  // TCP client for openvibe stimulations events
  private Client ov_TCPclient;
  // IP/port info
  private String IP = "127.0.0.1";
  private int Port = 11001;
  // string used to as terminal character while sending messages
  private final String STIM_SEPARATOR = "\n";
  // pointer to main prog in order to create new Client here
  // TODO: improve encapsulation
  private PApplet mainProg;

  // pending messages
  private Queue<String> mesQueue;

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
    reco();
    // new queue for our messages if something goes wrong
    mesQueue = new LinkedList<String>();
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

  // try to reconnect if connection is broken
  // send pending message as soon as possible
  public void update() 
  {
    // if connection is inactive, try to reco after TCPRetryDelay has been reached
    // FIXME: another way than creating a client? No reco in processing?
    if ( 
    (ov_TCPclient == null  || !ov_TCPclient.active()) // object not created or deco happend
    && millis() - TCPlastAttempt > TCP_RETRY_DELAY // and times up
    ) {
      reco();
    }

    // try to send messages in queue if connection is active
    if (mesQueue.size() > 0 && ov_TCPclient != null  && ov_TCPclient.active()) {
      println("Time to free queue.");
      while (mesQueue.size () > 0) {
        println(mesQueue.size() + " messages pending");
        // get ref to oldest message
        String heap = mesQueue.peek();
        // if we manage to send it now, remove it for good
        if (writeOrQueue(heap, false)) {
          mesQueue.remove();
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
  // enqueue: adds message to queue if true (we do not want to push a message already in the queue that we're trying to re-send)
  // return true if message sent
  // NB: adds separator '\n'
  private boolean writeOrQueue(String stimCode, boolean enqueue) {
    // has me message gone through?
    boolean sent = false;

    println("Try to send: " + stimCode);

    // if connection still active, give it a shot
    if (ov_TCPclient != null  && ov_TCPclient.active()) {
      // double check
      try {
        ov_TCPclient.write(stimCode+STIM_SEPARATOR);
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

    // time to check if we need to add message to queue
    if (!sent && enqueue) {
      mesQueue.add(stimCode);
      println("Message adedd to queue, now " + mesQueue.size() + " pending.");
    }

    return sent;
  }

  // send stimCode to TCP (will handle separator '\n')
  // return true if message sent right away, false if put in queue
  // WARNING: do not send message which contain '\n', will split stim in the end
  public boolean write(String stimCode) {
    // we don't want to loose messages from clients
    return writeOrQueue(stimCode, true);
  }
}

