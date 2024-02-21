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
PImage bball;
PImage bballhoop;
Spout spout;
Box2DProcessing box2d;
MidiBus myBus;
int midiINDevice  = 1;
int midiOUTDevice = 4;

//shapes
PShape leftKey;
PShape rightKey;
PShape midKey;
PShape midKeyRight;
PShape midKeyLeft;

//arraylists
ArrayList<Key> keys = new ArrayList<Key>();
ArrayList<Boundary> boundaries;
ArrayList<Box> boxes;
ArrayList<Particle> particles;
ArrayList<Ball> balls;
ArrayList<FloatList> queue;
ArrayList<FloatList> ballqueue;

//keyboard parameters
float keyLength = 165;
float blackWidth = 13;
float blackLength = .66;
float blackIntrude = .66;
float pitchBender = 64;
boolean sustain = false;
int activeNotes = 0;
int keysPressed = 0;

//game parameters
int gameMode = 0;
int passiveWin = 800;
boolean breakoutwin = false;
Boundary hoop;
Boundary lower;
Boundary upper;
Boundary left;
Boundary right;
float hoopx = 0;
float hoopy = width/2;
int hoopdirection = -1;
float paddleX = 0;
float paddleXTarget = 0;
float deadx = 0;
float deady = 0;
float deadt = 0;
boolean reset = false;
int cheatCooldown = 0;
float targetBallVelocity = 0;
float pyth(Vec2 vec) {
  return sqrt(vec.x*vec.x + vec.y*vec.y);
}

void setup() {
  size(1200, 1050, P3D);
  smooth();

  //load images
  bball = loadImage("bball-01.png");
  bballhoop = loadImage("bball-02.png");

  //set up spout
  spout = new Spout(this);
  spout.createSender("midi_test", width, height);

  //set up box2d
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.listenForCollisions();
  box2d.setGravity(0, 10);

  // Create ArrayLists
  boxes = new ArrayList<Box>();
  queue = new ArrayList<FloatList>();
  ballqueue = new ArrayList<FloatList>();
  balls = new ArrayList<Ball>();
  boundaries = new ArrayList<Boundary>();
  particles = new ArrayList<Particle>();

  //set up key boundaries
  int bnote = 0;
  for (int i = 0; i < 52; i++) {
    boundaries.add(new Boundary(width*i/52 + width/104, height - keyLength/2 - 10, width/52, keyLength, bnote, 0)); //white note
    bnote ++;
    if (i % 7 != 1 && i % 7 != 4 && i != 51) {
      boundaries.add(new Boundary(width*i/52 + width/52, height - keyLength + keyLength*blackLength/2-1, blackWidth, blackLength*keyLength, bnote, 0)); //black note
      bnote ++;
    }
  }

  //set up boundaries
  hoop = new Boundary(width/2, height/2, width/20, 20, -1, 0);
  left = new Boundary(-4, height/2, 8, height, -1, 0);
  upper = new Boundary(width/2, -4, width, 8, -1, 0);
  lower = new Boundary(width/2, height + 4, width, 8, -1, 0);
  right = new Boundary(width + 4, height/2, 8, height, -1, 0);
  boundaries.add(hoop);
  boundaries.add(upper);
  boundaries.add(lower);
  boundaries.add(left);
  boundaries.add(right);

  //set up virtual keys
  MidiBus.list();
  myBus = new MidiBus(this, midiINDevice, midiOUTDevice);
  for (int i = 0; i < 88; i ++) {
    keys.add(new Key());
  }

  //define shapes for keys
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

  //set up instruments
  myBus.sendMessage(0xC1, 0, 0, 00);
  myBus.sendMessage(0xC1, 1, 117, 00);
  myBus.sendMessage(0xC1, 2, 55, 00);
  myBus.sendMessage(0xC1, 3, 115, 00);
  myBus.sendMessage(0xC1, 4, 118, 00);

  background(0);
}

void dim() {
  blendMode(SUBTRACT);
  noStroke();
  fill(255, 2);
  rect(0, 0, width, height - keyLength);
  blendMode(BLEND);
}

void resetBreakout() {
  //delete all balls
  for (int i = 0; i < balls.size(); i++) {
    Ball b = balls.get(i);
    b.killBody();
  }
  balls.clear();

  //delete all excess boundaries
  for (int i = 93; i < boundaries.size(); i ++) {
    Boundary b = boundaries.get(i);
    b.killBody();
    boundaries.remove(i);
    i--;
  }

  //generate new level
  int missingrows = round(random(5));
  float cellWidth = width/16;
  float cellHeight = width/52;
  for (int i = 4; i < 24; i++) {
    int randomtype1 = floor(random(3));
    int randomtype2 = floor(random(3));
    for (int j = 1; j < 16; j ++) {
      if (i % max(missingrows, 2) != 0) {
        if (i % 2 == 0) {
          if (j < 15) {
            if (j % 2 == 0) {
              boundaries.add(new Boundary(j*cellWidth + cellWidth/2, i*cellHeight + cellHeight/2, cellWidth, cellHeight, -2, randomtype1));
            } else {
              boundaries.add(new Boundary(j*cellWidth + cellWidth/2, i*cellHeight + cellHeight/2, cellWidth, cellHeight, -2, randomtype2));
            }
          }
        } else {
          if (j % 2 == 0) {
            boundaries.add(new Boundary(j*cellWidth, i*cellHeight + cellHeight/2, cellWidth, cellHeight, -2, randomtype1));
          } else {
            boundaries.add(new Boundary(j*cellWidth, i*cellHeight + cellHeight/2, cellWidth, cellHeight, -2, randomtype2));
          }
        }
      }
    }
  }

  //spawn new ball
  Ball bl = new Ball(width/2, height/2, 10.0);
  balls.add(bl);

  //reset keys
  for (int i = 0; i < keys.size(); i++) {
    Key k = keys.get(i);
    background(0);
    k.unPress(i);
    k.enableRender();
  }
  for (int i = 0; i < boundaries.size(); i++) {
    Boundary b = boundaries.get(i);
    b.enableCollision();
  }
}

void win() {
  if (gameMode == 0) { //circles
    left.disableCollision();
    right.disableCollision();
    hoop.disableCollision();
    myBus.sendMessage(0xC1, 0, 4, 00);
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
    myBus.sendMessage(0xC1, 0, 18, 00);
  } else if (gameMode == 2) { //basektball
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.killBody();
      particles.remove(i);
    }
    resetBreakout();

    myBus.sendMessage(0xC1, 0, 80, 00);
  } else if (gameMode == 3) { //breakout
    for (int i = 0; i < keys.size(); i++) {
      keys.get(i).enableRender();
    }
    for (int i = 0; i < boundaries.size(); i++) {
      Boundary b = boundaries.get(i);
      if (i > 92) {
        b.killBody();
        boundaries.remove(i);
        i--;
      } else {
        b.enableCollision();
      }
    }
    gameMode = -1;
    myBus.sendMessage(0xC1, 0, 0, 00);
    for (int i = 0; i < balls.size(); i++) {
      Ball b = balls.get(i);
      b.killBody();
      balls.remove(i);
    }
    background(0);
  }
  for (int i = 0; i < keys.size(); i++) {
    Key k = keys.get(i);
    k.unPress(i);
    myBus.sendNoteOff(0, i+21, 60);
  }
  sustain = false;
  gameMode ++;
}

void draw() {
  if (reset) {
    resetBreakout();
    reset = false;
  }

  if (guide) {
    background(0, 255, 255);
    fill(0);
    rect(5, 5, width - 10, height - keyLength - 10);
  }

  if (gameMode == 0) {
    if (keysPressed > passiveWin) {
      keysPressed = 0;
      win();
    }
    if (pitchBender < 60) {
      blendMode(SUBTRACT);
      noStroke();
      fill(map(pitchBender, 60, 0, 0, 255), 10);
      rect(0, 0, width, height);
      blendMode(BLEND);
    } else if(pitchBender > 70) {
      blendMode(ADD);
      noStroke();
      fill(map(pitchBender, 70, 125, 0, 255), 10);
      rect(0, 0, width, height);
      blendMode(BLEND);
    }
  } else if (gameMode == 1) {
    background(0);
    for (int i = 0; i < queue.size(); i ++) {
      Box p = new Box(queue.get(i).get(0), queue.get(i).get(1), queue.get(i).get(2), queue.get(i).get(3), queue.get(i).get(4), queue.get(i).get(5));
      boxes.add(p);
    }
    queue.clear();
    if (keysPressed > passiveWin) {
      keysPressed = 0;
      win();
    }
  } else if (gameMode == 2) {
    background(0);
    box2d.setGravity(0, -100 + map(pitchBender, 0, 128, -100, 200));
    if (hoopx < 0) {
      hoopdirection = 1;
    } else if (hoopx > width) {
      hoopdirection = -1;
    }
    float hoopspeed = 52/max(particles.size(), 1);
    hoopx += hoopdirection * hoopspeed;
    hoop.setposition(hoopx, height/2);
    if (particles.size() == 0) {
      win();
    }
  } else if (gameMode == 3) {
    for (int i = 0; i < ballqueue.size(); i ++) {
      Ball b = new Ball(ballqueue.get(i).get(0), ballqueue.get(i).get(1), ballqueue.get(i).get(2));
      balls.add(b);
    }
    ballqueue.clear();

    //dim the screen slowly
    blendMode(SUBTRACT);
    noStroke();
    fill(255, 10);
    rect(0, 0, width, height);
    blendMode(BLEND);

    paddleX += (paddleXTarget - paddleX)*0.9;
    fill(0);
    rect(0, height - keyLength - 20, width, 20);
    hoop.setposition(width*paddleX/88, height - keyLength - 10);
    box2d.setGravity(0, map(pitchBender, 0, 127, -50, 50));
    for (int i = 0; i < balls.size(); i++) {
      Ball b = balls.get(i);
      if (b != null) {
        b.display();

        Vec2 vel2 = b.getBody().getLinearVelocity();
        float vel = pyth(vel2);
        if (sustain) {
          targetBallVelocity = 20;
        } else {
          targetBallVelocity = 50;
        }
        float vel_adj = targetBallVelocity/vel;
        b.setVelocity(new Vec2(vel_adj*vel2.x, vel_adj*vel2.y));
      }
    }
    if (breakoutwin) {
      keysPressed = 0;
      breakoutwin = false;
      win();
    }

    //animation after a block breaks
    if (deadt > 0 && boundaries.size() > 94) {
      blendMode(ADD);
      deadt --;
      fill(0);
      stroke(255);
      rect(deadx + (-10 + random(20))*deadt/20 - width/32, deady + (-10 + random(20))*deadt/20 - width/104, width/16, width/52);
      blendMode(BLEND);
    }
  }

  box2d.step(); //step through box2d world
  for (int i = 0; i < boundaries.size(); i++) {
    Boundary b = boundaries.get(i);
    if (b.done()) {
      boundaries.remove(b);
    } else if (b == hoop || b.getKey() < 0) {
      if (gameMode > 1) {
        b.display();
      }
    }
    if (gameMode == 2) {
      b.display();
    }
  }
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.display();
    if (p.done()) {
      particles.remove(i);
    }
  }
  for (int i = boxes.size()-1; i >= 0; i--) {
    Box b = boxes.get(i);
    if (b.done()) {
      boxes.remove(i);
    } else {
      b.display();
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
  spout.sendTexture();
}
