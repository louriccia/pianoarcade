// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Box2DProcessing example

// A rectangular box
class Box {

  Body body;
  float w;
  float h;
  float iVV;
  float bc;
  boolean delete = false;
  int age = 0;
  Box(float x, float y, float _w, float _h, float _iVV, float box_color) {
    w = _w;
    h = max(15, min(_h, height/2));
    bc = box_color;
    iVV = _iVV;
    makeBody(new Vec2(x, y), w, h);
    body.setUserData(this);
  }
  
  Body getBody(){
   return body; 
  }

  void killBody() {
    box2d.destroyBody(body);
  }
  
  void delete() {
    delete = true; 
  }

  boolean done() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    if (pos.y < 0 || pos.x < -20 || pos.x > width + 20) {
      killBody();
      return true;
    }
    return false;
  }
  
  int getAge(){
     return age; 
  }
  
  void change() {
     bc = 128; 
  }

  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    age ++;
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    if (bc == -1.0) {
      fill(0, 0, 255);
    } else {
      fill(bc, 255, 255);
    }
    stroke(0);
    rect(0, 0, w, h);
    popMatrix();
  }

  void makeBody(Vec2 center, float w_, float h_) {
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    body.setLinearVelocity(new Vec2(0, iVV));
    body.setAngularVelocity(random(-iVV/20, iVV/20));
  }
}
