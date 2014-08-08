
// will compute HR -- no more than 10% variations beatween beats, min and max values set, fall back to "medium" HR if timeout
// FIXME: check HR algo, evolution if noise or deco (eg. sudden from last HR to default if timeout ; and back to previous with first beat. maybe go smoother)

// does the same for the feedback given to user for debug
// FIXME: when agent changes, the first value of fakeHR will probably be wrong (we don't have a hint about current agent type, may be fixed)




// read network host/port from config file

class HeartManager implements Trigger {

  // current HR
  private int HR = Body.HR.MEDIUM.BPM;
  // current "fake" (feeback) HR
  private int fakeHR = Body.HR.MEDIUM.BPM;

  // set min and max values in case HR computation goes wrong
  private final int MIN_HR = 30;
  private final int MAX_HR = 200;
  // if no pulse is receive during this delay (in ms), will set HR to medium 
  private final int HR_TIMEOUT = 3000;
  // keep record of current timeout situation to avoid useless updates
  private boolean timeout = false;

  // read TCP inputs
  private TCPClientRead readBeats;
  // write stim to TCP
  private Trigger trig;

  // last time we saw a beat
  int lastBeat = 0;
  // last time we saw a *fake* beat
  int lastFakeBeat = 0;

  // Takes itself a trigger in order to pass Agent's beats to exterior...
  HeartManager(Trigger trig) {
    this.trig = trig;
    // give pointer to this class for Trigger interface
    readBeats = new TCPClientRead(beatIP, beatPort, this);
  }

  // update TCP stream, compute HR
  public void update() {
    readBeats.update();
    // if not already timedout, got back to default pulse
    if (!timeout && lastBeat + HR_TIMEOUT < millis()) {
      HR = Body.HR.MEDIUM.BPM;
      println("Timeout while waiting for beat, back to default: HR=" + HR);
      timeout = true;
    }
  }

  // pulse received from outside
  private void trueBeat() {
    // if we've been afk, we're well alive now
    timeout = false;
    // compute BPM: delay in ms then in minutes, then convert to freq
    int tick=millis();
    float perio_ms = (tick-lastBeat);
    float perio_m = perio_ms /(1000*60);
    int new_HR=(int)(1/perio_m);
    // clamp values to previous BPM +/- 10% and to min/max HR to avoid noise 
    new_HR=round(min(new_HR, HR+0.1*HR, MAX_HR));
    new_HR=round(max(new_HR, HR-0.1*HR, MIN_HR));
    println("Someone has pulsed! t=" + millis() + ", new HR: " + new_HR);
    HR=new_HR;
    lastBeat = tick;
  }

  // agent produced a pulse, compute displayed HR for debug and forward stim code
  private void fakeBeat(String code) {
    if (trig != null) {
      trig.sendMes(code);
    }
    // compute current fake HR, delay in ms then in minutes, then convert to freq
    int tick=millis();
    float perio_ms = (tick-lastFakeBeat);
    float perio_m = perio_ms /(1000*60);
    int fakeHR=(int)(1/perio_m);
    // do not clamp or anything: just report what's going one, we don't compute
    println("Feedback pulsed! t=" + millis() + ", new fakeHR: " + fakeHR);
    lastFakeBeat = tick;
  }

  // trigger interface: stimulus received, we reveice int code of hexa code of labels...
  public void sendMes(String code) {
    // OVTK_GDF_Beep is our code for beats!
    if (code.equals("OVTK_GDF_Beep")) {
      trueBeat();
    }
    // OVTK_GDF_Artifact_Pulse is the code for produced beat
    else if (code.equals("OVTK_GDF_Artifact_Pulse")) {
      fakeBeat(code);
    }
    else {
      println("Unknown code: [" + code + "] -- size: " + code.length() + ", time: " + millis());
    }
  }

  // return current BPM. used by agent to get heart body part
  public int getHR() {
    return HR;
  }
}

