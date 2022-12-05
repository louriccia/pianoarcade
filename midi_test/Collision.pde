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
    myBus.sendNoteOn(2, 92 - particles.size(), 80);
  } else if (o1 == hoop && o2.getClass() == Ball.class) { //breakout ball hits paddle
    Ball bl2 = (Ball) o2;
    Vec2 paddle_pos = box2d.getBodyPixelCoord(hoop.getBody());
    Vec2 ball_pos = box2d.getBodyPixelCoord(bl2.getBody());
    float newx = ball_pos.x - paddle_pos.x;
    bl2.setVelocity(new Vec2(newx, sqrt(max(40*40 - newx*newx, 20))));
  } else if (o1.getClass() == Boundary.class && o2.getClass() == Ball.class && gameMode == 3) { //breakout ball hits block
    Boundary p1 = (Boundary) o1;
    p1.setHit();
    if (p1.getKey() == -2) {
      deadt = 20;
      deadx = p1.getx();
      deady = p1.gety();
    }
    int hitkey = p1.getKey();
    if (hitkey >= 0 && hitkey < 88 && keys.get(hitkey).disabled()) { //hits key
      myBus.sendNoteOn(0, hitkey+21, 60);
      keys.get(hitkey).Press(hitkey, 60);
      p1.disableCollision();
      keys.get(hitkey).disableRender();
      boolean all_disabled = true;
      for (int i = 0; i < keys.size(); i++) {
        if (keys.get(i).disabled()) {
          all_disabled = false;
        }
      }
      if (all_disabled) {
        reset= true;
      }
    } else if (hitkey == -2 ) { //hits block
      if (boundaries.size() == 94) {
        breakoutwin = true;
      }
      float newballchance = random(100);
      if (newballchance < 1 && balls.size() < 4) {
        FloatList ball_data = new FloatList();
        ball_data.append(p1.getx());
        ball_data.append(p1.gety());
        ball_data.append(10.0);
        ballqueue.add(ball_data);
      }
      if (p1.getType() == 0) {
        myBus.sendNoteOn(1, round(random(50))+ 40, 80);
      } else if (p1.getType() == 1) {
        myBus.sendNoteOn(3, round(random(50))+ 40, 80);
      } else if (p1.getType() == 2) {
        myBus.sendNoteOn(4, round(random(50))+ 40, 80);
      }
      p1.delete();
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
