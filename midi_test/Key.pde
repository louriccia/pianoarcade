class Key {
  float velocity = 0;
  float initialVelocity = 0;
  Boolean on = false;
  Boolean sustained = false;
  PShape keyShape;
  int sat = 0;
  int duration = 0;
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
    { "1", (1-blackIntrude)*blackWidth},
    { "4", blackIntrude*blackWidth },
    { "6", (1-blackIntrude)*blackWidth },
    { "9", blackIntrude*blackWidth },
    { "11", blackWidth*.5 }
    });
  int[] black_notes = { 1, 4, 6, 9, 11 };
  int[] white_notes = {0, 2, 3, 5, 7, 8, 10};

  void Press(int vel) {
    on = true;
    velocity = vel;
    initialVelocity = vel;
    sat = 121 + (int)random(124);
  }
  void unPress() {
    if (!sustain) {
      on = false;
      duration = 0;
    } else {
      sustained = true;
    }
  }
  void unSustain() {
    if (sustained) {
      sustained = false;
      on = false;
      duration = 0;
    }
  }
  void render(int note) {
    if (on) {
      duration +=velocity;
    }
    Boolean black = false;
    for (int b = 0; b < black_notes.length; b++) {
      if (note%12 == black_notes[b]) {
        black = true;
      }
    }
    if (velocity > 0) {
      velocity -= 0.20;
    }
    int o = note % 12;
    int offset = 0;
    if (!black) {
      offset = whitemap.get(str(o));
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
    } else {
      offset = whitemap.get(str(o-1));
    }
    noStroke();
    if (black == true) {
      if (on == true) {
        fill(0, 0, velocity*3);
      } else {
        fill(0);
      }
      rect((note-5*floor(note/12) - offset)*width/52 - blackadjust.get(str(o)), height - keyLength, blackWidth, blackLength*keyLength);
    } else {
      if (on == true) {
        fill(((keysPressed*2)%255), sat, 255*(initialVelocity/80));
      } else {
        fill(255);
      }
      //rect((note-5*floor(note/12) - offset)*width/52, 300, width/52, 100);
      shape(keyShape, (note-5*floor(note/12) - offset)*width/52, height - keyLength);
    }
    if (on) {
      if (black) {
        circle((note-5*floor(note/12) - offset)* width/52, height - keyLength - initialVelocity*7 + 100, sqrt(duration));
      } else {
        circle((note-5*floor(note/12) - offset)* width/52 + width/104, height - keyLength - initialVelocity*7 + 100, sqrt(duration));
      }
    }
  }
}
