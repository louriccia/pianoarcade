//use 117 for
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

Boolean guide = false;

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
ArrayList<Particle> particles;
ArrayList<FloatList> queue;
Ball ball;
//Spring spring;
MidiBus myBus;

int midiINDevice  = 1;
int midiOUTDevice = 4;
float keyLength = 165;
float blackWidth = 13;
float blackLength = .66;
float blackIntrude = .66;
int instrument = 0;
float pitchBender = 64;
boolean sustain = false;
int keysPressed = 0;
int activeNotes = 0;
int gameMode = 0;
Boundary hoop;
Boundary lower;
Boundary upper;
Boundary left;
Boundary right;
float hoopx = 0;
float hoopy = width/2;
int direction = -1;
float pyth(Vec2 vec) {
  return sqrt(vec.x*vec.x + vec.y*vec.y);
}

int cheatCooldown = 0;

float paddleX = 0;
float paddleXTarget = 0;
float targetBallVelocity = 0;

void setup() {
  size(1200, 1050, P3D);
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
  // Create the empty list
  particles = new ArrayList<Particle>();

  ball = new Ball(width/4, height/4, 10.0);

  int bnote = 0;
  for (int i = 0; i < 52; i++) {
    boundaries.add(new Boundary(width*i/52 + width/104, height - keyLength/2 - 10, width/52, keyLength, bnote)); //white note
    bnote ++;
    if (i % 7 != 1 && i % 7 != 4 && i != 51) {
      boundaries.add(new Boundary(width*i/52 + width/52, height - keyLength + keyLength*blackLength/2-1, blackWidth, blackLength*keyLength, bnote)); //black note
      bnote ++;
    }
  }

  hoop = new Boundary(width/2, height/2, width/20, 20, -1);
  boundaries.add(hoop);
  // Add a bunch of fixed boundaries
  left = new Boundary(0, height/2, 0.2, height, -1);
  upper = new Boundary(width/2, 0, width, 0.2, -1);
  lower = new Boundary(width/2, height, width, 0.2, -1);
  right = new Boundary(width, height/2, 0.2, height, -1);
  boundaries.add(upper);
  boundaries.add(lower);
  boundaries.add(left);
  boundaries.add(right);

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

  myBus.sendMessage(0xC1, 0, instrument, 00);
  myBus.sendMessage(0xC1, 1, 117, 00);
  // myBus.sendMessage(0xC1, 0, instrument, 00); //change instrument
  //myBus.sendMessage(0xC1, 1, 35, 00); //change instrument
  if (gameMode == 2) {
    for (int i = 0; i < 52; i++) {
      particles.add(new Particle(width*i/52 + width/104, height - keyLength - 50, width/104));
    }
  } else if (gameMode == 3) {
    float cellWidth = 20;
    float cellHeight = 20;
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j ++) {
        boundaries.add(new Boundary(j*width/cellWidth + width/cellWidth*2, i*cellHeight + cellHeight/2, width/cellWidth, cellHeight, -2));
      }
    }
  }
}

void dim() {
  blendMode(SUBTRACT);
  noStroke();
  fill(255, 2);
  rect(0, 0, width, height - keyLength);
  blendMode(BLEND);
}

void win() {
  if (gameMode == 0) { //circles
    left.disableCollision();
    right.disableCollision();
    hoop.disableCollision();
  } else if (gameMode == 1) { //boxes
    for (int i = boxes.size()-1; i >= 0; i--) {
      Box b = boxes.get(i);
      b.killBody();
      boxes.remove(i);
    }
    for (int i = 0; i < 52; i++) {
      particles.add(new Particle(width*i/52 + width/104, height - keyLength - 50, width/104));
    }
    left.enableCollision();
    right.enableCollision();
    hoop.enableCollision();
  } else if (gameMode == 2) { //basektball
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.killBody();
      particles.remove(i);
    }
    float cellWidth = width/16;
    float cellHeight = width/52;
    for (int i = 2; i < 16; i++) {
      for (int j = 1; j < 15; j ++) {
        boundaries.add(new Boundary(j*cellWidth + cellWidth/2, i*cellHeight + cellHeight/2, cellWidth, cellHeight, -2));
      }
    }
    ball = new Ball(width/2, height/2, 10.0);
    //b.resetPosition();
  } else if (gameMode == 3) { //breakout
    ball = null;
    for (int i = 0; i < keys.size(); i++) {
      keys.get(i).enableRender();
    }
    gameMode = -1;
  }
  if (gameMode == 5) {
    gameMode = -1 ;
    background(0);
  }
  for (int i = 0; i < keys.size(); i++) {
    Key k = keys.get(i);
    background(0);
    k.unPress(i);
  }
  sustain = false;
  gameMode ++;
}

void draw() {
  //background(0);
  //rect(globalNote*width/88, 300, 20, 100);

  if (guide) {
    background(0, 255, 255);
    fill(0);
    rect(5, 5, width - 10, height - 10);
  }

  if (gameMode == 0) {
    if (keysPressed == 1000) {
      keysPressed = 0;
      win();
    }

    //blendMode(SUBTRACT);
    //noStroke();
    //fill(255, 2);
    //if (frameCount%32 == 0) {
    //  rect(0, 0, width, height - keyLength);
    //}
    //blendMode(BLEND);
  } else if (gameMode == 1) {
    background(0);
    for (int i = 0; i < queue.size(); i ++) {
      Box p = new Box(queue.get(i).get(0), queue.get(i).get(1), queue.get(i).get(2), queue.get(i).get(3), queue.get(i).get(4), queue.get(i).get(5));
      boxes.add(p);
    }
    queue.clear();
    if (keysPressed == 1000) {
      keysPressed = 0;
      win();
    }
  } else if (gameMode == 2) {

    background(0);
    box2d.setGravity(0, -100);

    if (hoopx < 0) {
      direction = 1;
    } else if (hoopx > width) {
      direction = -1;
    }
    float hoopspeed = 52/max(particles.size(), 1);
    hoopx += direction * hoopspeed;
    hoopy = height/2 + map(pitchBender, 0, 127, height/4, -height/4);
    hoop.setposition(hoopx, hoopy);
    if (particles.size() == 0) {
      win();
    }
  } else if (gameMode == 3) {
    paddleX += (paddleXTarget - paddleX)*0.9;
    hoop.setposition(width*paddleX/88, height - keyLength - 10);
    background(30);
    box2d.setGravity(0, map(pitchBender, 0, 127, -50, 50));
    Ball b = ball;
    b.display();
    Vec2 vel2 = ball.getBody().getLinearVelocity();
    float vel = pyth(vel2);
    if (sustain) {
      targetBallVelocity = 20;
    } else {
      targetBallVelocity = 60;
    }
    float vel_adj = targetBallVelocity/vel;
    ball.setVelocity(new Vec2(vel_adj*vel2.x, vel_adj*vel2.y));
    if (boundaries.size() == 93) {
      keysPressed = 0;
      win();
    }
  }

  // We must always step through time!
  box2d.step();

  // Display all the boundaries
  for (int i = 0; i < boundaries.size(); i++) {
    Boundary b = boundaries.get(i);
    if (b.done()) {
      boundaries.remove(b);
    } else if (gameMode != 3  || b == hoop || b.getKey() < 0) {
      if (gameMode > 1) {
        b.display();
      }
    }
  }

  // Display all the boxes
  for (Box b : boxes) {
    b.display();
  }

  // Look at all particles
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.display();
    // Particles that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    if (p.done()) {
      particles.remove(i);
    }
  }

  // Boxes that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = boxes.size()-1; i >= 0; i--) {
    Box b = boxes.get(i);
    if (b.done()) {
      boxes.remove(i);
    }
  }

  int cheat = 0;
  for (int i = 0; i < keys.size(); i++) {
    Key k = keys.get(i);
    if (k.played() && i % 3 == 0) {
      cheat ++;
    }
    if (gameMode == 3 && !boundaries.get(i).done()) {
      k.render(i);
    } else if ( gameMode != 3) {
      k.render(i);
    }
  }
  if (cheat == 10 && cheatCooldown <= 0 && activeNotes == 10) {
    win();
    cheatCooldown = 50;
  }
  if (cheatCooldown > 0) {
    cheatCooldown --;
  }
  colorMode(HSB);
  println(keysPressed);
  spout.sendTexture();
}
