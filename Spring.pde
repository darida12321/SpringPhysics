
// A spring between two physics objects
class Spring{
  PhysicsObject obj1;
  PhysicsObject obj2;
  float s;
  float l;
  float d = 10;

  Spring(PhysicsObject obj1, PhysicsObject obj2, float s){
    this.obj1 = obj1;
    this.obj2 = obj2;
    this.s = s;
    this.l = obj1.pos.dist(obj2.pos);
  }
  Spring(PhysicsObject obj1, PhysicsObject obj2, float s, float l){
    this.obj1 = obj1;
    this.obj2 = obj2;
    this.s = s;
    this.l = l;
  }

  void update(float dt){
    float distance = obj2.pos.dist(obj1.pos);
    PVector direction = obj2.pos.copy().sub(obj1.pos).normalize();
    PVector deltaVel = obj2.vel.copy().sub(obj1.vel);

    float dampening = deltaVel.dot(direction) * d;
    float totalForce = (distance-l)*s + dampening;
    PVector springForce = direction.mult(totalForce);


    obj1.applyForce(springForce);
    obj2.applyForce(springForce.mult(-1));
  }

  void display(){
    stroke(0, 0, 255);
    strokeWeight(10);
    line(obj1.pos.x, obj1.pos.y, obj2.pos.x, obj2.pos.y);
  }
}
