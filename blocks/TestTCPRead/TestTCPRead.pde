
// program to test TCP beat reading through from openvibe

TCPClientRead readBeats;

void setup() {
  // create client for beats
  readBeats = new TCPClientRead(this, BeatIP, BeatPort);
}

void draw() {
  // update beats reading
  readBeats.update();
}

// a beat event has been recorded -- probably by TCPClient
public void beat() {
  println("Beat recorded at t=" + millis());
}
