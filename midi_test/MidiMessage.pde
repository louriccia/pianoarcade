void midiMessage(MidiMessage message, long timestamp, String bus_name) {
  int unk = (int)(message.getMessage()[0] & 0xFF) ;
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  int n = note - 21;
  if (unk == 144 || unk == 128) {
    Key k = keys.get(n);
    if (unk == 144) { //NOTE ON
      paddleXTarget = n;
      k.Press(n, vel);
      keysPressed++;
      activeNotes ++;
      if (gameMode !=3 || (gameMode == 3 && !boundaries.get(n).done())) {
        myBus.sendNoteOn(0, n+21, vel);
      }
      //myBus.sendNoteOn(1, n+21, vel);
      if (n == 0) {
        instrument++;
        myBus.sendMessage(0xC1, 0, instrument, 00);
      }
      if (gameMode == 2) {
        keys.get(n).setPVelocity(vel);
      }
    } else if (unk == 128) { // NOTE OFF
      try {
        //if (gameMode == 1) {
        // k.spawnBox(n);
        //}
        k.unPress(n);
        activeNotes --;
        myBus.sendNoteOff(0, n+21, vel);
      }
      catch (Exception e) {
        println("there was an error");
      }
    }
  } else if (unk == 176) { //SUSTAIN
    myBus.sendMessage(0xB0, 0, 0x40, vel);
    if (vel == 127) {
      sustain = true;
    } else if (vel == 0) {
      sustain = false;
      for (int i = 0; i < keys.size(); i++) {
        keys.get(i).unSustain(i);
      }
    }
  } else if (unk == 224) { //PITCH BENDER
    if (vel < 64) {
      //pitchBender += (64 - vel)/2;
    } else {
      //pitchBender -= (vel - 64)/2;
    }
    pitchBender = vel;
    println(pitchBender);
    //pitchBender = max(0, pitchBender);
    //pitchBender = min(pitchBender, height - keyLength);
    //println(pitchBender);
    float gravity = map(pitchBender, 0, 125, -100, 100);
    box2d.setGravity(0, gravity);
  }
  //println(unk + ": Note "+ note + ", vel " + vel);
}