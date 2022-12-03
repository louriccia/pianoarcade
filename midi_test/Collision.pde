// Collision event functions!
void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1.getClass() == Boundary.class && o2.getClass() == Box.class) { //physics splashback
    Boundary p1 = (Boundary) o1;
    //p1.change();

    float vel = pyth(b2.getLinearVelocity());
    //println(b2.getLinearVelocity().toString(), vel);
    Box p2 = (Box) o2;
    int hitkey = p1.getKey();
    if (p2.getAge() > 10 && hitkey < 88 && hitkey >= 0 && keys.get(hitkey).getCooldown() <= 0) {
      //p2.change();
      if (hitkey > -1 && pitchBender > 30) {
        keys.get(hitkey).setCooldown(50);
        myBus.sendNoteOn(0, hitkey+21, round(vel));
        keys.get(hitkey).Press(hitkey, round(vel));
      }
    }
  } else if (o1 == hoop && o2.getClass() == Particle.class && b2.getLinearVelocity().y < 0) { //make a basket
    Particle p2 = (Particle) o2;
    p2.delete();
  } else if (o1 == hoop && o2 == ball) { //breakout ball hits paddle
    Vec2 paddle_pos = box2d.getBodyPixelCoord(hoop.getBody());
    Vec2 ball_pos = box2d.getBodyPixelCoord(ball.getBody());
    float newx = ball_pos.x - paddle_pos.x;
    ball.setVelocity(new Vec2(newx, sqrt(max(40*40 - newx*newx, 10))));
  } else if (o1.getClass() == Boundary.class && o2 == ball && gameMode == 3) { //breakout ball hits block
    Boundary p1 = (Boundary) o1;
    int hitkey = p1.getKey();
    if (hitkey >= 0 && hitkey < 88 && keys.get(hitkey).disabled()) {
      myBus.sendNoteOn(0, hitkey+21, 60);
      keys.get(hitkey).Press(hitkey, 60);
      p1.disableCollision();
      keys.get(hitkey).disableRender();
    } else if (hitkey == -2) { //hits block
      myBus.sendNoteOn(1, round(random(50))+ 40, 80);
      p1.delete();
      println(boundaries.size());
    }
  }
}

// Objects stop touching each other
void endContact(Contact cp) {
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1.getClass() == Boundary.class && o2.getClass() == Box.class) {
    Boundary p1 = (Boundary) o1;
    Box p2 = (Box) o2;
    int hitkey = p1.getKey();
    if (p2.getAge() > 10 && hitkey < 88) {
      //p2.change();
      if (hitkey > -1) {
        myBus.sendNoteOff(0, hitkey+21, 0);
        keys.get(hitkey).unPress(hitkey);
      }
    }
  }
}
