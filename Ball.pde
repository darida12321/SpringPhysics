
// A ball bouncing off of the edges
class Ball extends PhysicsObject{
  float r;

  Ball(PVector pos, PVector vel, float mass, float r){
    super(pos, vel, mass);
    this.r = r;
  }
  Ball(PVector pos, float mass, float r){
    super(pos, mass);
    this.r = r;
  }
  Ball(float x, float y, float mass, float r){
    super(x, y, mass);
    this.r = r;
  }

  boolean pointInObject(PVector point){
    return point.copy().sub(pos).mag() < r;
  }
  void update(float dt){
    if(pos.x - r < 0){ pos.x = r; vel.x = abs(vel.x); }
    if(pos.y - r < 0){ pos.y = r; vel.y = abs(vel.y); }
    if(pos.x + r > width ){ pos.x = width-r;  vel.x = -abs(vel.x); }
    if(pos.y + r > height){ pos.y = height-r; vel.y = -abs(vel.y); }
    super.update(dt);
  }

  void display(){
    stroke(0);
    fill(255);
    if(selected){
      fill(255, 0, 0);
    }
    ellipse(pos.x, pos.y, 2*r, 2*r);
  }
}
