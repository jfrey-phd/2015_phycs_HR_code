

// l'endroit que j'ai modifié !

void serialEvent(Serial port) {
  String inData = port.readStringUntil('\n');

  // won't try to do anything with string if we received nothing 
  if (inData == null || inData.length() == 0) {
    return;
  }
  inData = trim(inData);                 // cut off white space (carriage return)

  println("[" + inData + "] -- size: " + inData.length()) ;

  // not better if we had empty characters
  if (inData.length() == 0) {
    return;
  }

  // convert the string to usable int
  Sensor = int(inData);
}

