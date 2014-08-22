
//  VARIABLES
int pulsePin = 0;                 // Pulse Sensor purple wire connected to analog pin 0

// these variables are volatile because they are used during the interrupt service routine!
volatile int Signal;                // holds the incoming raw data

void setup() {
  // pulse sensor works best with 3.3V supply, may need the following line depending on your arduino model.
  //analogReference(EXTERNAL);
  // unleash Due power!
  analogReadResolution(12);
  Serial.begin(115200);             // we agree to talk fast!
}

void loop() {
  Signal = analogRead(pulsePin);
  // the data to send culminating in a carriage return
  Serial.println(Signal);
  // simulating a 500hz recordings
  delay(2);                             //  take a break
}
