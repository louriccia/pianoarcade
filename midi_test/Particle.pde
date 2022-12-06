// <http://www.shiffman.net/teaching/nature>

class Particle {
  Body body;
  float r;
  boolean done = false;
  color col;


  Particle(float x, float y, float r_) {
    r = r_;
    makeBody(x, y, r);
    body.setUserData(this);
    col = color(175);
  }

  void killBody() {
    box2d.destroyBody(body);
  }

  void delete() {
    done = true;
  }

  boolean done() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    if (done) {
      killBody();
    } else if (pos.y < 0 || pos.x <0 || pos.x > width || pos.y > height) {
      body.setTransform(new Vec2(width/2, height/2), 0.0);
      return true;
    }
    return done;
  }

  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    noStroke();
    if (gameMode == 2) {
      bball.resize(width/52, width/52);
      image(bball, -width/104, -width/104);
    } else {
      ellipse(0, 0, r*2, r*2);
    }
    popMatrix();
  }

  void makeBody(float x, float y, float r) {
    BodyDef bd = new BodyDef();
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = box2d.createBody(bd);
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 1;
    fd.friction = 0.2;
    fd.restitution = 0.8; //how much energy is maintained after collision
    body.createFixture(fd);
  }
}
