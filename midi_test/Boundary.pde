class Boundary {
  Body body;
  float x;
  float y;
  float w;
  float h;
  boolean delete = false;
  int associated_key = 0;
  int hit = 0;
  int type = 0;

  Boundary(float x_, float y_, float w_, float h_, int k, int type_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    type = type_;
    associated_key = k;
    // Define the polygon
    makeBody(new Vec2(x, y), w, h);
    body.setUserData(this);
  }

  void setAngularVelocity(float a) {
    body.setAngularVelocity(a);
  }
  void setVelocity(Vec2 v) {
    body.setLinearVelocity(v);
  }

  void killBody() {
    box2d.destroyBody(body);
  }

  boolean done() {
    if (delete) {
      killBody();
      return true;
    }
    return false;
  }

  void disableCollision() {
    body.getFixtureList().setSensor(true);
  }

  void enableCollision() {
    body.getFixtureList().setSensor(false);
  }

  void setposition(float x, float y) {
    Vec2 pos = body.getWorldCenter();
    Vec2 target = box2d.coordPixelsToWorld(x, y);
      Vec2 diff = new Vec2((target.x-pos.x)*2.2, (target.y-pos.y)*2.2);
      diff.mulLocal(50);
      setVelocity(diff);
      setAngularVelocity(0);
  }

  int getKey() {
    return associated_key;
  }

  Body getBody() {
    return body;
  }

  void setHit() {
    hit = 50;
  }

  int getHit() {
    return hit;
  }

  float getx() {
    return x;
  }

  int getType() {
    return type;
  }

  float gety() {
    return y;
  }

  void display() {
    if (hit > 0) {
      hit --;
    }
    if (!done()) {
      Vec2 pos = box2d.getBodyPixelCoord(body);
      float a = body.getAngle();

      rectMode(PConstants.CENTER);
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(a);

      if (this == hoop && gameMode == 2) {
        noStroke();
        bballhoop.resize(141, 159);
        image(bballhoop, -69, -107);
      } else {
        if (hit > 0) {
          fill(255);
        } else if (gameMode == 2) {
          fill(255);
        } else {
          fill(type*80, 255, 255);
        }
        stroke(0);
        rect((random(10) - 5)*hit/50, (random(10) - 5)*hit/50, w, h);
      }
      popMatrix();
    } else if (hit > 50) {
      fill(255);
      rect((random(20) - 10)*hit/50, (random(20) - 10)*hit/50, w, h);
    }
  }

  void makeBody(Vec2 center, float w_, float h_) {
    BodyDef bd = new BodyDef();
    bd.type = BodyType.KINEMATIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    bd.fixedRotation = true;
    body = box2d.createBody(bd);
    PolygonShape ps = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    ps.setAsBox(box2dW, box2dH);
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.density = 1.0;
    fd.friction = 0.5;
    fd.restitution = 0.1;
    body.createFixture(fd);
  }

  void delete() {
    delete = true;
  }
}
