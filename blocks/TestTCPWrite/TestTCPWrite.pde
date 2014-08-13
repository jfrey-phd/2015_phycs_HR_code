
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
  // send label 1
  if (key == ' ') {
    writeStims.write("OVTK_StimulationId_Label_01");
  }
  // default code
  else {
    writeStims.write("OVTK_GDF_Incorrect");
  }
}

