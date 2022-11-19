
// SimpleMidi.pde
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;

import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.dynamics.contacts.*;
import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage;
import spout.*;

Spout spout;
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
//Spring spring;
MidiBus myBus;

int midiINDevice  = 1;
int midiOUTDevice = 5;
float keyLength = 200;
float blackWidth = 20;
float blackLength = .6;
float blackIntrude = .6;
int instrument = 0;
float pitchBender = 64;
boolean sustain = false;
int keysPressed = 0;
int activeNotes = 0;
int gameMode = 2;

float pyth(Vec2 vec) {
  return sqrt(vec.x*vec.x + vec.y*vec.y);
}

void setup() {
  size(1600, 1000, P3D);
  smooth();
  spout = new Spout(this);
  spout.createSender("midi_test", width, height);
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

  int bnote = 0;
  for (int i = 0; i < 52; i++) {
    boundaries.add(new Boundary(width*i/52 + width/104, height - keyLength/2 - 10, width/52, keyLength, bnote)); //white note
    bnote ++;
    if (i % 7 != 1 && i % 7 != 4) {
      boundaries.add(new Boundary(width*i/52 + width/52, height - keyLength + keyLength*blackLength/2-1, blackWidth, blackLength*keyLength, bnote)); //black note
      bnote ++;
    }
  }

  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(width/2, 0, width, 0, -1));
  boundaries.add(new Boundary(width/2, height, width, 0, -1));

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

  // myBus.sendMessage(0xC1, 0, instrument, 00); //change instrument
  //myBus.sendMessage(0xC1, 1, 35, 00); //change instrument
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
    for (int i = 0; i < queue.size(); i ++) {
      Box p = new Box(queue.get(i).get(0), queue.get(i).get(1), queue.get(i).get(2), queue.get(i).get(3), queue.get(i).get(4), queue.get(i).get(5));
      boxes.add(p);
    }
    queue.clear();
  }

  // We must always step through time!
  box2d.step();

  // Display all the boundaries
  for (Boundary wall : boundaries) {
    wall.display();
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
  //circle(8, pitchBender, 5);
  spout.sendTexture();
}

void midiMessage(MidiMessage message, long timestamp, String bus_name) {
  int unk = (int)(message.getMessage()[0] & 0xFF) ;
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  int n = note - 21;
  if (unk == 144 || unk == 128) {
    Key k = keys.get(n);
    if (unk == 144) { //NOTE ON
      k.Press(n, vel);
      keysPressed++;
      activeNotes ++;
      myBus.sendNoteOn(0, n+21, vel);
      //myBus.sendNoteOn(1, n+21, vel);
      if (n == 0) {
        instrument++;
        myBus.sendMessage(0xC1, 0, instrument, 00);
      }
      if(gameMode == 2){
        Boundary b = boundaries.get(n);
        b.setVelocity(new Vec2(0, vel));
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
    //pitchBender = max(0, pitchBender);
    //pitchBender = min(pitchBender, height - keyLength);
    //println(pitchBender);
    float gravity = map(pitchBender, 0, 125, -100, 100);
    box2d.setGravity(0, gravity);
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
    Boundary p1 = (Boundary) o1;
    //p1.change();

    float vel = pyth(b2.getLinearVelocity());
    //println(b2.getLinearVelocity().toString(), vel);
    Box p2 = (Box) o2;
    int hitkey = p1.getKey();
    if (p2.getAge() > 10 && hitkey < 88) {
      //p2.change();
      if (hitkey > -1) {
        myBus.sendNoteOn(0, hitkey+21, round(vel/2));
        keys.get(hitkey).Press(hitkey, round(vel/2));
      }
    }
  }
}

// Objects stop touching each other
void endContact(Contact cp) {
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1.getClass() == Boundary.class && o2.getClass() == Box.class) {
    Boundary p1 = (Boundary) o1;
    Box p2 = (Box) o2;
    int hitkey = p1.getKey();
    if (p2.getAge() > 10 && hitkey < 88) {
      //p2.change();
      if (hitkey > -1) {
        myBus.sendNoteOff(0, hitkey+21, 0);
        keys.get(hitkey).unPress(hitkey);
      }
    }
  }
}
