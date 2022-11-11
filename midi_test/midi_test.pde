
// SimpleMidi.pde
import shiffman.box2d.*;
import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage;
Box2DProcessing box2d;
PShape leftKey;
PShape rightKey;
PShape midKey;
PShape midKeyRight;
PShape midKeyLeft;
int globalNote = 0;
ArrayList<Key> keys = new ArrayList<Key>();
MidiBus myBus;

int midiDevice  = 1;
float keyLength = 100;
float blackWidth = 20;
float blackLength = .6;
float blackIntrude = .6;

void setup() {
  size(1600, 400);
  MidiBus.list();
  myBus = new MidiBus(this, midiDevice, 1);
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
}

void draw() {
  //background(0);
  //rect(globalNote*width/88, 300, 20, 100);
  for (int i = 0; i < keys.size(); i++) {
    Key k = keys.get(i);
    k.render(i);
  }
}

void midiMessage(MidiMessage message, long timestamp, String bus_name) {
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  int n = note - 21;
  Key k = keys.get(n);
  println(n % 12);
  if (vel == 100) {
    k.Press();
  } else {
    k.unPress();
  }
  println("Bus " + bus_name + ": Note "+ note + ", vel " + vel);
}
