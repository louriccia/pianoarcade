class Key {
  float velocity = 0;
  float initialVelocity = 0;
  Boolean on = false;
  Boolean sustained = false;
  PShape keyShape;
  int sat = 0;
  int duration = 0;
  float physicsVelocity = 0;
  int dur = 0;
  FloatList box_data;
  IntDict whitemap = new IntDict(new Object[][] {
    { "0", 0 },
    { "2", 1 },
    { "3", 1 },
    { "5", 2 },
    { "7", 3 },
    { "8", 3 },
    { "10", 4 }
    });
  FloatDict blackadjust = new FloatDict(new Object[][] {
    { "0", 0.0},
    { "1", (1-blackIntrude)*blackWidth},
    { "2", 0.0},
    { "3", 0.0},
    { "4", blackIntrude*blackWidth },
    { "5", 0.0},
    { "6", (1-blackIntrude)*blackWidth },
    { "7", 0.0},
    { "8", 0.0},
    { "9", blackIntrude*blackWidth },
    { "10", 0.0},
    { "11", blackWidth*.5 }
    });
  int[] black_notes = { 1, 4, 6, 9, 11 };
  int[] white_notes = {0, 2, 3, 5, 7, 8, 10};

  Boolean black(int note) {
    Boolean bl = false;
    for (int b = 0; b < black_notes.length; b++) {
      if (note%12 == black_notes[b]) {
        bl = true;
      }
    }
    return bl;
  }
  int getOffset(int note) {
    int o = note % 12;
    if (black(note)) {
      return max(whitemap.get(str(o-1)), 0);
    } else {
      return max(whitemap.get(str(o)), 0);
    }
  }
  void Press(int note, int vel) {
    if (on) {
      spawnBox(note);
    }
    dur = 0;
    on = true;
    velocity = vel;
    initialVelocity = vel;
    sat = 121 + (int)random(124);
  }

  void spawnBox(int note) {
    if (dur != 0) {
      box_data = new FloatList();
      if (black(note)) {
        box_data.append((note-5*floor(note/12) - getOffset(note))* width/52 - blackadjust.get(str(note%12)) + blackWidth/2);
      } else {
        box_data.append((note-5*floor(note/12) - getOffset(note))* width/52  + width/104);
      }
      box_data.append(height - keyLength - dur/2);
      if (black(note)) {
        box_data.append(blackWidth);
      } else {
        box_data.append(width/52);
      }
      box_data.append(dur);
      box_data.append(initialVelocity*2);
      if (black(note)) {
        box_data.append(-1);
      } else {
        box_data.append((keysPressed*2)%255);
      }

      queue.add(box_data);
    }
  }
  void unPress(int note) {
    if (!sustain) {
      if (gameMode == 1) {
        spawnBox(note);
      }
      on = false;
      duration = 0;
      dur = 0;
    } else {
      sustained = true;
    }
  }
  void unSustain(int note) {
    if (sustained) {
      if (gameMode == 1) {
        spawnBox(note);
      }
      sustained = false;
      on = false;
      duration = 0;
      dur = 0;
    }
  }
  void setPVelocity(int vel) {
    physicsVelocity = vel;
  }
  void render(int note) {
    rectMode(CORNER);
    noStroke();
    Boolean blk = black(note);
    int o = note % 12;
    int offset = getOffset(note);
    float note_x = (note-5*floor(note/12) - offset)* width/52;

    if (on) {
      duration +=velocity;
      dur += 2;
    }
    if (physicsVelocity > 0.1 && !on) {
      physicsVelocity *= 0.94;
    }
    if (!blk) {
      boundaries.get(note).setposition(note_x + width/104, height - keyLength/2 - map(physicsVelocity, 0, 127, 0, keyLength));
    } else {
      boundaries.get(note).setposition(note_x + blackWidth/2 - blackadjust.get(str(o)), height + -keyLength + keyLength*blackLength/2 - map(physicsVelocity, 0, 127, 0, keyLength*blackLength));
    }
    if (velocity > 0) {
      velocity -= 0.20;
    }
    if (!blk) {
      if (note == 0 || o == 3 || o == 8) {
        keyShape = leftKey;
      } else if (o == 2 || o == 7) {
        keyShape = rightKey;
      } else if (o == 5) {
        keyShape = midKey;
      } else if (o == 10) {
        keyShape = midKeyLeft;
      } else if (o == 0) {
        keyShape = midKeyRight;
      }
      if (on == true) {
        if (gameMode == 0) {
          fill(((keysPressed*2)%255), sat, 255*(initialVelocity/80));
          circle(note_x + width/104, height - keyLength - initialVelocity*7 + 100, sqrt(duration));
        } else if (gameMode == 1) {
          fill(((keysPressed*2)%255), 255, 255);
        }
      } else {
        fill(255);
      }
      shape(keyShape, note_x, height - keyLength);
    } else {
      if (on == true) {
        if (gameMode == 0) {
          fill(0, 0, initialVelocity*3);
          circle(note_x, height - keyLength - initialVelocity*7 + 100, sqrt(duration));
        } else if (gameMode == 1) {
          fill(255, 0, 255);
        }
      } else {
        fill(0);
      }
      rect(note_x - blackadjust.get(str(o)), height - keyLength, blackWidth, blackLength*keyLength);
    }

    if (gameMode == 1 && on) {
      fill(125);
      if (black(note)) {
        fill(255, 0, 255);
        rect(note_x - blackadjust.get(str(o)), height - keyLength - dur, blackWidth, dur);
      } else {
        fill(((keysPressed*2)%255), 255, 255);
        rect(note_x, height - keyLength - dur, width/52, dur);
      }
    }
  }
}
