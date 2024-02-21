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
      if (gameMode == 3) {
        for (int i = 0; i < keys.size(); i++) {
          myBus.sendNoteOff(0, i+21, vel);
        }
      }
      if (gameMode !=3) {
        myBus.sendNoteOn(0, n+21, vel);
      } else if ((gameMode == 3 && keys.get(n).disabled())) {
        myBus.sendNoteOn(0, n+21, 60);
      }

      if (gameMode == 2) {
        keys.get(n).setPVelocity(vel);
      }
    } else if (unk == 128) { // NOTE OFF
      try {
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
    pitchBender = vel;
    float gravity = map(pitchBender, 0, 125, -100, 100);
    
    box2d.setGravity(0, gravity);
  }
}
