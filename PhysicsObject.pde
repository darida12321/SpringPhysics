
// Simulate a generic physics object
abstract class PhysicsObject{
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  float mass;
  float friction = 0.99;
  boolean selected = false;

  PhysicsObject(PVector pos, PVector vel, float mass){
    this.pos = pos;
    this.vel = vel;
    this.mass = mass;
  }
  PhysicsObject(PVector pos, float mass){
    this.pos = pos;
    this.mass = mass;
  }
  PhysicsObject(float x, float y, float mass){
    this.pos = new PVector(x, y);
    this.mass = mass;
  }

  void applyForce(PVector force){
    if(mass == 0){ return; }
    acc.add(force.copy().div(mass));
  }
  boolean pointInObject(PVector point){
    return false;
  }

  void update(float dt){
    if(selected){
      pos.x += mouseX - pmouseX;
      pos.y += mouseY - pmouseY;
      acc.mult(0);
      return;
    }
    vel.add(acc.copy().mult(dt));
    pos.add(vel.copy().mult(dt));
    acc.mult(0);
    vel.mult(friction);
  }

  void display(){
    fill(255, 0, 0); noStroke();
    ellipse(pos.x, pos.y, 10, 10);
  }
}
