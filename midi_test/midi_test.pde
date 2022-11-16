
// SimpleMidi.pde
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage;
Box2DProcessing box2d;
PShape leftKey;
PShape rightKey;
PShape midKey;
PShape midKeyRight;
PShape midKeyLeft;
ArrayList<Key> keys = new ArrayList<Key>();
// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
// A list for all of our rectangles
ArrayList<Box> boxes;
ArrayList<FloatList> queue;
MidiBus myBus;

int midiINDevice  = 1;
int midiOUTDevice = 3;
float keyLength = 200;
float blackWidth = 20;
float blackLength = .6;
float blackIntrude = .6;
int instrument = 0;
float colorPickerY = 0;
boolean sustain = false;
int keysPressed = 0;
int activeNotes = 0;
int gameMode = 1;

void setup() {
  size(1600, 1000);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  
   // Turn on collision listening!
  box2d.listenForCollisions();
  // We are setting a custom gravity
  box2d.setGravity(0, 10);

  // Create ArrayLists
  boxes = new ArrayList<Box>();
  queue = new ArrayList<FloatList>();
  boundaries = new ArrayList<Boundary>();

  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(width/2, 0, width, 0));
  boundaries.add(new Boundary(width/2, height - keyLength, width, 0));
  //boundaries.add(new Boundary(3*width/4,height-keyLength,width/2-50,10));

  MidiBus.list();
  background(0);
  myBus = new MidiBus(this, midiINDevice, midiOUTDevice);
  for (int i = 0; i < 88; i ++) {
    keys.add(new Key());
  }
  leftKey = createShape();
  leftKey.beginShape();
  leftKey.vertex(0, 0);
  leftKey.vertex(width/52 - blackWidth*blackIntrude, 0);
  leftKey.vertex(width/52 - blackWidth*blackIntrude, keyLength*blackLength);
  leftKey.vertex(width/52, keyLength*blackLength);
  leftKey.vertex(width/52, keyLength);
  leftKey.vertex(0, keyLength);
  leftKey.endShape(CLOSE);
  leftKey.disableStyle();

  rightKey = createShape();
  rightKey.beginShape();
  rightKey.vertex(blackWidth*blackIntrude, 0);
  rightKey.vertex(width/52, 0);
  rightKey.vertex(width/52, keyLength);
  rightKey.vertex(0, keyLength);
  rightKey.vertex(0, keyLength*blackLength);
  rightKey.vertex(blackWidth*blackIntrude, keyLength*blackLength);
  rightKey.endShape(CLOSE);
  rightKey.disableStyle();

  midKey = createShape();
  midKey.beginShape();
  midKey.vertex(blackWidth*(1-blackIntrude), 0);
  midKey.vertex(width/52 - blackWidth*(1-blackIntrude), 0);
  midKey.vertex(width/52 - blackWidth*(1-blackIntrude), keyLength*blackLength);
  midKey.vertex(width/52, keyLength*blackLength);
  midKey.vertex(width/52, keyLength);
  midKey.vertex(0, keyLength);
  midKey.vertex(0, keyLength*blackLength);
  midKey.vertex(blackWidth*(1-blackIntrude), keyLength*blackLength);
  midKey.endShape(CLOSE);
  midKey.disableStyle();

  midKeyRight = createShape();
  midKeyRight.beginShape();
  midKeyRight.vertex(blackWidth*.5, 0);
  midKeyRight.vertex(width/52 - blackWidth*(1-blackIntrude), 0);
  midKeyRight.vertex(width/52 - blackWidth*(1-blackIntrude), keyLength*blackLength);
  midKeyRight.vertex(width/52, keyLength*blackLength);
  midKeyRight.vertex(width/52, keyLength);
  midKeyRight.vertex(0, keyLength);
  midKeyRight.vertex(0, keyLength*blackLength);
  midKeyRight.vertex(blackWidth*.5, keyLength*blackLength);
  midKeyRight.endShape(CLOSE);
  midKeyRight.disableStyle();

  midKeyLeft = createShape();
  midKeyLeft.beginShape();
  midKeyLeft.vertex(blackWidth*(1-blackIntrude), 0);
  midKeyLeft.vertex(width/52 - blackWidth*.5, 0);
  midKeyLeft.vertex(width/52 - blackWidth*.5, keyLength*blackLength);
  midKeyLeft.vertex(width/52, keyLength*blackLength);
  midKeyLeft.vertex(width/52, keyLength);
  midKeyLeft.vertex(0, keyLength);
  midKeyLeft.vertex(0, keyLength*blackLength);
  midKeyLeft.vertex(blackWidth*(1-blackIntrude), keyLength*blackLength);
  midKeyLeft.endShape(CLOSE);
  midKeyLeft.disableStyle();

  myBus.sendMessage(0xC1, 0, instrument, 00); //change instrument
  myBus.sendMessage(0xC1, 1, 35, 00); //change instrument
}

void draw() {
  //background(0);
  //rect(globalNote*width/88, 300, 20, 100);

  if (gameMode == 0) {
    blendMode(SUBTRACT);
    noStroke();
    fill(255, 2);
    if (frameCount%32 == 0) {
      rect(0, 0, width, height - keyLength);
    }
    blendMode(BLEND);
  } else if (gameMode == 1) {
    background(0);
    for(int i = 0; i < queue.size(); i ++){
        Box p = new Box(queue.get(i).get(0), queue.get(i).get(1), queue.get(i).get(2), queue.get(i).get(3), queue.get(i).get(4), queue.get(i).get(5));
        boxes.add(p);
    }
    queue.clear();
  }

  // We must always step through time!
  box2d.step();

  // Display all the boundaries
  for (Boundary wall : boundaries) {
    //wall.display();
  }

  // Display all the boxes
  for (Box b : boxes) {
    b.display();
  }

  // Boxes that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = boxes.size()-1; i >= 0; i--) {
    Box b = boxes.get(i);
    if (b.done()) {
      boxes.remove(i);
    }
  }

  for (int i = 0; i < keys.size(); i++) {
    Key k = keys.get(i);
    k.render(i);
  }
  if (frameCount % 10 == 0) {
    //myBus.sendMessage(0xC1,  0, instrument, 00); //change instrument
    //instrument ++;
    int randomNote = (int)random(80);
    //myBus.sendNoteOn(0, randomNote, 60); //channel 0 should work
    //keys.get(randomNote).Press(60);
  }
  colorMode(HSB);
  //fill(255*(frameCount%(height - keyLength))/(height - keyLength), 255, 255);
  //rect(0, frameCount%(height-keyLength), 5, 1);
  //fill(0);
  //rect(5, 0, 10, height - keyLength);
  //fill(255);
  //circle(8, colorPickerY, 5);
}

void midiMessage(MidiMessage message, long timestamp, String bus_name) {
  int unk = (int)(message.getMessage()[0] & 0xFF) ;
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  int n = note - 21;
  if (unk == 144 || unk == 128) {
    Key k = keys.get(n);
    if (unk == 144) { //NOTE ON
      k.Press(vel);
      keysPressed++;
      activeNotes ++;
      myBus.sendNoteOn(0, n+21, vel);
      //myBus.sendNoteOn(1, n+21, vel);
      if (n == 0) {
        instrument++;
        myBus.sendMessage(0xC1, 0, instrument, 00);
      }
    } else if (unk == 128) { // NOTE OFF
      try {
        if (gameMode == 1) {
          k.spawnBox(n);
        }
        k.unPress();
        activeNotes --;
        myBus.sendNoteOff(0, n+21, vel);
      }
      catch (Exception e){
        println("there was an error");
      }
    }
  } else if (unk == 176) {
    myBus.sendMessage(0xB0, 0, 0x40, vel);
    if (vel == 127) {
      sustain = true;
    } else if (vel == 0) {
      sustain = false;
      for (int i = 0; i < keys.size(); i++) {
        keys.get(i).unSustain();
      }
    }
  } else if (unk == 224) {
    if (vel < 64) {
      colorPickerY += (64 - vel)/2;
    } else {
      colorPickerY -= (vel - 64)/2;
    }
    colorPickerY = max(0, colorPickerY);
    colorPickerY = min(colorPickerY, height - keyLength);
  }
  //println(unk + ": Note "+ note + ", vel " + vel);
}

// Collision event functions!
void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1.getClass() == Boundary.class && o2.getClass() == Box.class) {
    Box p1 = (Box) o1;
    p1.change();
    Box p2 = (Box) o2;
    p2.change();
  }

}

// Objects stop touching each other
void endContact(Contact cp) {
}
