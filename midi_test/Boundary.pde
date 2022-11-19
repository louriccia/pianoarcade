// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2012
// Box2DProcessing example

// A fixed boundary class

class Boundary {

  // A boundary is a simple rectangle with x,y,width,and height
  float x;
  float y;
  float w;
  float h;
  boolean delete = false;
  int associated_key = 0;

  // But we also have to make a body for box2d to know about it
  Body b;

  Boundary(float x_, float y_, float w_, float h_, int k) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    associated_key = k;
    // Define the polygon
    PolygonShape ps = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // We're just a box
    ps.setAsBox(box2dW, box2dH);


    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.KINEMATIC;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    bd.fixedRotation = true;
    b = box2d.createBody(bd);

    // Attached the shape to the body using a Fixture
    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    b.createFixture(fd);

    b.setUserData(this);
  }
  
  void setVelocity(Vec2 v) {
    println(associated_key);
     b.setLinearVelocity(box2d.coordPixelsToWorld(v));
  }

  int getKey() {
    return associated_key;
  }
  
  Body getBody() {
   return b; 
  }

  // Draw the boundary, if it were at an angle we'd have to do something fancier
  void display() {
    fill(128);
    stroke(0);
    rectMode(CENTER);
    rect(x, y, w, h);
  }

  void delete() {
    delete = true;
  }
}
