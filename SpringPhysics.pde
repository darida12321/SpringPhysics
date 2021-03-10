
// Simulate a generic physics object
abstract class PhysicsObject{
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  float mass;

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

  void update(float dt){
    vel.add(acc.copy().mult(dt));
    pos.add(vel.copy().mult(dt));
    acc.mult(0);
    vel.mult(0.993);
  }

  void display(){
    fill(255, 0, 0); noStroke();
    ellipse(pos.x, pos.y, 10, 10);
  }
}

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

  void update(float dt){
    if(pos.x - r < 0){ pos.x = r; vel.x = abs(vel.x); }
    if(pos.y - r < 0){ pos.y = r; vel.y = abs(vel.y); }
    if(pos.x + r > width ){ pos.x = width-r;  vel.x = -abs(vel.x); }
    if(pos.y + r > height){ pos.y = height-r; vel.y = -abs(vel.y); }
    super.update(dt);
  }

  void display(){
    fill(255, 0, 0); noStroke();
    ellipse(pos.x, pos.y, 2*r, 2*r);
  }
}

class MouseBall extends PhysicsObject{
  float r;

  MouseBall(float r){
    super(new PVector(0, 0), new PVector(0, 0), 0);
    this.r = r;
  }

  void update(float dt){
    pos.x = mouseX;
    pos.y = mouseY;
  }

  void display(){
    fill(0, 255, 0); noStroke();
    ellipse(pos.x, pos.y, 2*r, 2*r);
  }
}

class Spring extends PhysicsObject{
  PhysicsObject obj1;
  PhysicsObject obj2;
  float d;
  float l;

  Spring(PhysicsObject obj1, PhysicsObject obj2, float d){
    super(new PVector(0, 0), new PVector(0, 0), 0);
    this.obj1 = obj1;
    this.obj2 = obj2;
    this.d = d;
    this.l = obj1.pos.dist(obj2.pos);
  }
  Spring(PhysicsObject obj1, PhysicsObject obj2, float d, float l){
    super(new PVector(0, 0), new PVector(0, 0), 0);
    this.obj1 = obj1;
    this.obj2 = obj2;
    this.d = d;
    this.l = l;
  }

  void update(float dt){
    PVector diff = obj2.pos.copy().sub(obj1.pos);
    float dist = diff.mag();
    //if(dist < l){ return; }

    PVector dir = diff.normalize();
    PVector force = dir.mult((dist-l)*d);

    obj1.applyForce(force);
    obj2.applyForce(force.mult(-1));
  }

  void display(){
    stroke(0, 0, 255);
    strokeWeight(10);
    line(obj1.pos.x, obj1.pos.y, obj2.pos.x, obj2.pos.y);
  }
}

class Rope extends PhysicsObject{
  ArrayList<PhysicsObject> objs = new ArrayList<PhysicsObject>();
  ArrayList<Spring> springs = new ArrayList<Spring>();
  Tracer tracker = new Tracer(new PVector(0, 0), 200);

  Rope(PhysicsObject obj, float n, float diff){
    super(new PVector(0, 0), new PVector(0, 0), n*50);

    objs.add(obj);
    PVector pos = obj.pos.copy();
    for(int i = 0; i < n; i++){
      pos.add(new PVector(0, diff));
      objs.add(new Ball(pos.copy(), 50, diff/2));
      springs.add(new Spring(objs.get(i), objs.get(i+1), 5000, 20));
    }
  }

  void applyForce(PVector force){
    if(springs.size() == 0){ return; }
    force.div(springs.size());
    for(int i = 1; i < objs.size(); i++){
      objs.get(i).applyForce(force);
    }
  }

  void update(float dt){
    for(int i = 1; i < objs.size(); i++){
      objs.get(i).update(dt);
    }
    for(Spring spring : springs){
      spring.update(dt);
    }
    tracker.addPoint(objs.get(objs.size()-1).pos);
  }

  void display(){
    for(int i = 1; i < objs.size(); i++){
      objs.get(i).display();
    }
    for(Spring spring : springs){
      spring.display();
    }
    tracker.display();
  }
}

class EinsteinianSolid extends PhysicsObject{
  ArrayList<PhysicsObject> objs = new ArrayList<PhysicsObject>();
  ArrayList<Spring> springs = new ArrayList<Spring>();

  EinsteinianSolid(float x, float y, int n, float diff){
    super(new PVector(0, 0), new PVector(0, 0), n*50);

    for(int dy = -n; dy <= n; dy++){
      for(int dx = -n; dx <= n; dx++){
        objs.add(new Ball(new PVector(x+dx*diff, y+dy*diff), 50, 25));
      }
    }

    int side = 2*n+1;
    objs.set(n*side + n, new MouseBall(25));

    float sqrt2 = sqrt(2);
    for(int bx = 0; bx < side-1; bx++){
      for(int by = 0; by < side-1; by++){
        PhysicsObject obj = objs.get(by * side + bx);
        PhysicsObject objR = objs.get(by * side + (bx+1));
        PhysicsObject objB = objs.get((by+1) * side + bx);
        PhysicsObject objBR = objs.get((by+1) * side + (bx+1));

        springs.add(new Spring(obj, objR, 5000, diff));
        springs.add(new Spring(obj, objB, 5000, diff));
        springs.add(new Spring(obj, objBR, 5000, diff*sqrt2));
        springs.add(new Spring(objR, objB, 5000, diff*sqrt2));
      }
    }

    for(int bx = 0; bx < side-1; bx++){
      PhysicsObject obj = objs.get((side-1) * side + bx);
      PhysicsObject objR = objs.get((side-1) * side + (bx+1));
      springs.add(new Spring(obj, objR, 5000, diff));
    }

    for(int by = 0; by < side-1; by++){
      PhysicsObject obj = objs.get(by * side + (side-1));
      PhysicsObject objB = objs.get((by+1) * side + (side-1));
      springs.add(new Spring(obj, objB, 5000, diff));
    }


  }

  void applyForce(PVector force){
    force.div(objs.size());
    for(PhysicsObject obj : objs){
      obj.applyForce(force);
    }
  }

  void update(float dt){
    for(PhysicsObject obj : objs){
      obj.update(dt);
    }
    for(Spring spring : springs){
      spring.update(dt);
    }
  }

  void display(){
    for(PhysicsObject obj : objs){
      obj.display();
    }
    for(Spring spring : springs){
      spring.display();
    }
  }
}



class PhysicsManager{
  ArrayList<PhysicsObject> objects = new ArrayList<PhysicsObject>();
  long lastUpdateTime = millis();

  PhysicsObject add(PhysicsObject object){
    objects.add(object);
    return object;
  }

  void applyGravity(PVector force){
    for(PhysicsObject object : objects){
      object.applyForce(force.copy().mult(object.mass));
    }
  }

  void update(){
    float dt = (float)(millis() - lastUpdateTime) / 1000;

    for(PhysicsObject object : objects){
      object.update(dt);
    }

    lastUpdateTime = millis();
  }

  void display(){
    for(PhysicsObject object : objects){
      object.display();
    }
  }
}

PhysicsManager manager = new PhysicsManager();

void setup() {
  size(800, 800);
  frameRate(6000);

  //PhysicsObject b = manager.add(new MouseBall(20));
  //manager.add(new Rope(b, 10, 30));

  manager.add(new EinsteinianSolid(400, 400, 2, 100));
}

void draw(){

  manager.applyGravity(new PVector(0, 1000));
  manager.update();

  background(0);
  manager.display();
}
