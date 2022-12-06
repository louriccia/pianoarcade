// <http://www.shiffman.net/teaching/nature>

class Ball {

  Body body;
  float r;
  boolean done = false;
  color col;
  BodyDef bd = new BodyDef();

  Ball(float x, float y, float r_) {
    r = r_;
    makeBody(x, y, r);
    body.setUserData(this);
    col = color(175);
  }

  void killBody() {
    box2d.destroyBody(body);
  }

  Body getBody() {
    return body;
  }

  void resetPosition() {
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(width/4, height/4)));
  }

  void setVelocity(Vec2 vec) {
    body.setLinearVelocity(vec);
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


  //
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    fill(255);
    noStroke();
    ellipse(0, 0, r*2, r*2);    
    popMatrix();
  }

  void makeBody(float x, float y, float r) {
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = box2d.createBody(bd);
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    fd.density = 0.02;
    fd.friction = 0.0;
    fd.restitution = 1.0; //how much energy is maintained after collision

    body.createFixture(fd);
    body.setBullet(true);
    body.setLinearVelocity(new Vec2(30, 30));
  }
}
