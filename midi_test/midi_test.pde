
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
ArrayList<Key> keys = new ArrayList<Key>();
MidiBus myBus;

int midiINDevice  = 3;
int midiOUTDevice = 6;
float keyLength = 200;
float blackWidth = 20;
float blackLength = .6;
float blackIntrude = .6;
int instrument = 0;
float colorPickerY = 0;
boolean sustain = false;
int keysPressed = 0;

void setup() {
  size(1600, 800);
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
}

void draw() {
  //background(0);
  //rect(globalNote*width/88, 300, 20, 100);
  for (int i = 0; i < keys.size(); i++) {
    Key k = keys.get(i);
    k.render(i);
  }
  if (frameCount % 10 == 0) {
    //myBus.sendMessage(0xC0,  0, instrument, 00); //changes instrument
    myBus.sendMessage(0xC1,  0, instrument, 00);
    instrument ++;
    int randomNote = (int)random(80);
    //myBus.sendNoteOn(0, randomNote, 60); //channel 0 should work
    //keys.get(randomNote).Press(60);
  }
  colorMode(HSB);
  fill(255*(frameCount%(height - keyLength))/(height - keyLength), 255, 255);
  rect(0, frameCount%(height-keyLength), 5, 1);
  fill(0);
  rect(5, 0, 10, height - keyLength);
  fill(255);
  circle(8, colorPickerY, 5);
}

void midiMessage(MidiMessage message, long timestamp, String bus_name) {
  int unk = (int)(message.getMessage()[0] & 0xFF) ;
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  int n = note - 21;
  if (unk == 144 || unk == 128) {
    Key k = keys.get(n);
    if (unk == 144) {
      k.Press(vel);
      keysPressed++;
      myBus.sendNoteOn(0, n+21, vel);
    } else if (unk == 128) {
      myBus.sendNoteOff(0, n+21, vel);
      k.unPress();
    }
  } else if (unk == 176){
     if(vel == 127){
        sustain = true;
     } else if (vel == 0){
        sustain = false;
        for(int i = 0; i < keys.size(); i++){
          keys.get(i).unSustain();
        }
     }
  } else if (unk == 224){
    if(vel < 64){
      colorPickerY += (64 - vel)/2;
    } else {
      colorPickerY -= (vel - 64)/2;
    }
    colorPickerY = max(0, colorPickerY);
    colorPickerY = min(colorPickerY, height - keyLength);
  }
  println(unk);
  println("Bus " + bus_name + ": Note "+ note + ", vel " + vel);
}
