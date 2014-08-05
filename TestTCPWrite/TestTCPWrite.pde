
// program to test TCP beat reading through from openvibe

TCPClientWrite writeStims;

void setup() {
  // create client for beats
  writeStims = new TCPClientWrite(this, BeatIP, BeatPort);
}

void draw() {
  // update beats writing
  writeStims.update();
}

// send stims when key press
void keyPressed() {
  // debug TTS
  if (key == ' ') {
    writeStims.write("into_space!\n");
  }
  // speak sad
  else {
    writeStims.write("unknown_key\n");
  }
}

