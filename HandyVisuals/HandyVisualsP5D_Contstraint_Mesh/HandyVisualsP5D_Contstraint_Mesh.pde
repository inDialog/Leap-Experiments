import com.onformative.leap.LeapMotionP5;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.Hand;
import peasy.*;
import punktiert.math.Vec;
import punktiert.physics.*;

//physics system for mesh
VPhysicsSimple physics;
//physics for constraints
VPhysicsSimple physicsConstraints;


PeasyCam cam;

boolean pause = true;

LeapMotionP5 leap;

// number of particles in the scene
int amount = 200;


int x;
int y;
float outerRad;
float innerRad;

PVector f1;
// Size of each cell in the grid, ratio of window size to video size
// 80 * 8 = 640
// 60 * 8 = 480
int videoScale = 50;

// Number of columns and rows in our system
int cols, rows;


public void setup() {
  size(800, 800, P3D);
  leap = new LeapMotionP5(this);
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2000);

  cols = width/videoScale;
  rows = height/videoScale;


  physics = new VPhysicsSimple();
  BConstantForce force = new BConstantForce(0, 0, .1f);
  physics.addBehavior(force);

  physicsConstraints = new VPhysicsSimple();
  physicsConstraints.addBehavior(new BAttraction(new Vec(), 1000, 1f));

  //lock all the Constraints (otherwise the springforce will alter the position
  VParticle a = new VParticle(-width * .5f, -height * .5f).lock();
  VParticle b = new VParticle(width * .5f, -height * .5f).lock();
  VParticle c = new VParticle(width * .5f, height * .5f).lock();
  VParticle d = new VParticle(-width * .5f, height * .5f).lock();

  //add the Particles as Constraints to the mesh physics
  physics.addConstraint(a);
  physics.addConstraint(b);
  physics.addConstraint(c);
  physics.addConstraint(d);

  //add the Particles as Particles to the constraint physics
  physicsConstraints.addParticle(a);
  physicsConstraints.addParticle(b);
  physicsConstraints.addParticle(c);
  physicsConstraints.addParticle(d);


  //create a mesh
  float amountX = 100;
  float amountY = 50;

  float strength = 1f;
  ArrayList<VParticle> particles = new ArrayList<VParticle>();

  for (int i = 0; i <= amountY; i++) {
    Vec a0 = a.interpolateTo(d, i / amountY);
    Vec b0 = b.interpolateTo(c, i / amountY);

    for (int j = 0; j <= amountX; j++) {
      Vec pos = a0.interpolateTo(b0, j / amountX);
      VParticle p = physics.addParticle(new VParticle(pos));
      particles.add(p);

      if (j > 0) {
        //getParticle gives you the equal particle or constraint 
        VParticle previous = physics.getParticle(particles.get(particles.size() - 2));
        VSpring s = new VSpring(p, previous, p.sub(previous).mag(), strength);
        physics.addSpring(s);
      }
      if (i > 0) {
        VParticle above = physics.getParticle(particles.get(particles.size() - (int) amountX - 2));
        VSpring s = new VSpring(p, above, p.sub(above).mag(), strength);
        physics.addSpring(s);
      }
    }
  }
 
}

public void draw() {
  background(255);

physics.update();


  noFill();

  // Begin loop for columns
  for (int i = 0; i < cols; i++) {
    // Begin loop for rows
    for (int j = 0; j < rows; j++) {
      //


      // Scaling up to draw a rectangle at (x,y)
      int x = i*videoScale;
      int y = j*videoScale;


      noFill();
      stroke(170, 170, 170);
      // For every column and row, a rectangle is drawn at an (x,y) location scaled and sized by videoScale.
      rect(x, y, videoScale, videoScale);
    }
  }


  for (Hand hand : leap.getHandList()) {


    PVector handPos = leap.getPosition(hand);
    PVector sphere_center = leap.getSphereCenter(hand);
    float sphere_radius = leap.getSphereRadius(hand);
    //PVector handStable = leap.getStabilizedPosition(hand);

    stroke(0, 255, 0);
    strokeWeight(1);
    float ellipseSizeHand = map(handPos.z, 300, -400, handPos.z/10, handPos.z/5);
    ellipse(handPos.x, handPos.y, ellipseSizeHand, ellipseSizeHand);

    arc(handPos.x, handPos.y, 60, 60, PI, TWO_PI);

    stroke(0);
    pushMatrix();
    translate(handPos.x, handPos.y, handPos.z);
    scale(10);
    beginShape();
    vertex(-1, -1, -1);
    vertex( 1, -1, -1);
    vertex( 0, 0, 1);

    vertex( 1, -1, -1);
    vertex( 1, 1, -1);
    vertex( 0, 0, 1);

    vertex( 1, 1, -1);
    vertex(-1, 1, -1);
    vertex( 0, 0, 1);

    vertex(-1, 1, -1);
    vertex(-1, -1, -1);
    vertex( 0, 0, 1);
    endShape();
    popMatrix();


    for (Finger finger : leap.getFingerList()) {
      PVector fingerPos = leap.getTip(finger);
      stroke(255, 0, 0);

      line(handPos.x, handPos.y, handPos.z, 
      fingerPos.x, fingerPos.y, fingerPos.z);
      float ellipseSizeHandStable = map(fingerPos.z, 300, -400, fingerPos.z/10, fingerPos.z/5);
      ellipse(fingerPos.x, fingerPos.y, ellipseSizeHandStable, ellipseSizeHandStable);
      println("finger" + fingerPos);
      //particle
      stroke(200, 0, 0);
      // set pos to fingerPosition
      
        // before you update you have to unlock the constarints
  for (VParticle c : physicsConstraints.particles) {
    c.unlock();
    //if you have just local forces
    //c.update();
    //c.lock();
  }
  //if you have forces attached to the physics class update so
  physicsConstraints.update();
  for (VParticle c : physicsConstraints.particles) {
    c.lock();
  }

  strokeWeight(2);
  stroke(100);
  for (VParticle p : physics.particles) {
    point(p.x, p.y, p.z);
  }
  strokeWeight(5);
  stroke(200, 0, 0);
  for (VParticle p : physics.constraints) {
    point(fingerPos.x, fingerPos.y, fingerPos.z);
  }

   
      noStroke();


      stroke(0, 0, 255);
      arc(fingerPos.x, fingerPos.y, 60, 60, PI, TWO_PI);
      stroke(0, 200, 200);
      strokeWeight(1);
      pushMatrix();
      translate(fingerPos.x, fingerPos.y, fingerPos.z);
      sphereDetail(10, 10);
      sphere(5);

      popMatrix();
    
    }
  }
}
public void stop() {
  leap.stop();
}

