// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Box2DProcessing example

// A circular particle

class Ball {

  // We need to keep track of a Body and a radius
  Body body;
  float r;
  boolean done = false;
  color col;
  BodyDef bd = new BodyDef();

  Ball(float x, float y, float r_) {
    r = r_;
    // This function puts the particle in the Box2d world
    makeBody(x, y, r);
    body.setUserData(this);
    col = color(175);
  }

  // This function removes the particle from the box2d world
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

  // Change color when hit
  void delete() {
    done = true;
  }

  // Is the particle ready for deletion?
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
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    fill(255);
    noStroke();
    ellipse(0, 0, r*2, r*2);
    // Let's add a line so we can see the rotation
    line(0, 0, r, 0);
    popMatrix();
  }

  // Here's our function that adds the particle to the Box2D world
  void makeBody(float x, float y, float r) {
    // Define a body

    // Set its position
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;

    body = box2d.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    // Parameters that affect physics
    fd.density = 0.02;
    fd.friction = 0.0;
    fd.restitution = 1.0; //how much energy is maintained after collision

    // Attach fixture to body
    body.createFixture(fd);
    body.setBullet(true);
    body.setLinearVelocity(new Vec2(30, 30));
  }
}
